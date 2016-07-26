# - Add targets to update ABI dump and check ABI compatibility
#
# TODO Docs
# TODO Make it possible to store ABI dumps at arbitrary service
#
# Simple example:
# add_abi_check_target(
#     TARGET somelib
#     SKIP_HEADERS
#         "${CMAKE_CURRENT_SOURCE_DIR}/test"
#         "${CMAKE_CURRENT_SOURCE_DIR}/another-path/test"
#   )
#
#

#=============================================================================
# Copyright 2015-2016 by Alex Turbov <i.zaufi@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of this repository, substitute the full
#  License text for the above reference.)


include(CMakeParseArguments)

find_program(ABI_COMPLIANCE_CHECKER_EXECUTABLE abi-compliance-checker)
if(ABI_COMPLIANCE_CHECKER_EXECUTABLE)
    message(STATUS "Found abi-compliance-checker: ${ABI_COMPLIANCE_CHECKER_EXECUTABLE}")
else()
    message(STATUS "WARNING: `abi-compliance-checker` not found. Won't check ABI compliance...")
endif()

find_program(JQ_EXECUTABLE jq)
if(JQ_EXECUTABLE)
    message(STATUS "Found jq: ${JQ_EXECUTABLE}")
else()
    message(STATUS "WARNING: `jq` not found. Won't check ABI compliance...")
endif()

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(STATUS "WARNING: To check ABI compliance GCC is the must...")
endif()

set(_ADD_ABI_CHECK_TARGET_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}")
set(_ADD_ABI_CHECK_TARGET_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(_ADD_ABI_CHECK_TARGET_XML_TEMPLATE "${CMAKE_CURRENT_LIST_DIR}/library-abi.xml.in")

if(NOT ADD_ABI_CHECK_TARGET_DEBUG AND "$ENV{add_abi_check_target_DEBUG}")
    set(ADD_ABI_CHECK_TARGET_DEBUG ON)
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

function(add_abi_check_target)
    set(options DEBUG)
    set(one_value_args ARTIFACTORY_REPO ARTIFACTORY_USER ARTIFACTORY_PASS DIRECTORY TARGET VERSION)
    set(multi_value_args HEADERS SKIP_HEADERS SOURCES)
    cmake_parse_arguments(add_abi_check_target "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    # Enable debug mode if it was requested via CMake CLI or environment
    if(NOT add_abi_check_target_DEBUG AND ADD_ABI_CHECK_TARGET_DEBUG)
        set(add_abi_check_target_DEBUG ON)
    endif()

    # `abi-compliance-checker` needs GCC
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        if(add_abi_check_target_DEBUG)
            message(STATUS "  [add_abi_check_target] CXX compiler is not GCC. Exiting...")
        endif()
        return()
    endif()

    # Check that `jq` is here...
    if(NOT JQ_EXECUTABLE)
        if(add_abi_check_target_DEBUG)
            message(STATUS "  [add_abi_check_target] `jq` wasn't found. Exiting...")
        endif()
        return()
    endif()

    if(NOT add_abi_check_target_ARTIFACTORY_REPO)
        message(FATAL_ERROR "No `ARTIFACTORY_REPO` has been given in call to `add_abi_check_target()`")
    endif()

    # `TARGET` is a mandatory option
    if(NOT TARGET ${add_abi_check_target_TARGET})
        message(FATAL_ERROR "`${add_abi_check_target_TARGET}' is not a target name")
    endif()
    get_target_property(_is_imported ${add_abi_check_target_TARGET} IMPORTED)
    if(_is_imported)
        message(FATAL_ERROR "Target `${add_abi_check_target_TARGET}' should not be imported one")
    endif()
    get_target_property(_target_type ${add_abi_check_target_TARGET} TYPE)
    if(_target_type STREQUAL "MODULE_LIBRARY" OR _target_type STREQUAL "SHARED_LIBRARY")
        # No additional options needed
    elseif(_target_type STREQUAL "STATIC_LIBRARY")
        set(add_abi_check_target_ABI_CHECK_OPTIONS "-static-libs")
    else()
        message(FATAL_ERROR "Target `${add_abi_check_target_TARGET}` has unsupported type ${_target_type}")
    endif()

    # Preset some options for ABI checker
    set(add_abi_check_target_ABI_CHECKER_DIR "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-abi-checker")
    file(MAKE_DIRECTORY "${add_abi_check_target_ABI_CHECKER_DIR}")

    # Prepare target properties for future including
    # ATTENTION CMake protect accessing `LOCATION` property of targets, so it is really
    # (impossible) to get a full path and a filename of it in currently executed `CMakeLists.txt`.
    # So here is a trick: render a `*.cmake` file w/ needed properties and include it at the moment
    # of custom targets execution.
    # ATTENTION At the very first time, a file generated is not immediatly flushed!
    # So, do not even try to `include()` it right after generation!
    set(
        add_abi_check_target_TARGET_PROPS_FILE
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-abi-check-target-properties.cmake"
      )
    file(
        GENERATE
        OUTPUT "${add_abi_check_target_TARGET_PROPS_FILE}"
        CONTENT "
            set(add_abi_check_target_TARGET_FILE_NAME \"$<TARGET_FILE_NAME:${add_abi_check_target_TARGET}>\")
            set(add_abi_check_target_TARGET_FILE_DIR \"$<TARGET_FILE_DIR:${add_abi_check_target_TARGET}>\")
        "
      )

    if(NOT add_abi_check_target_VERSION)
        get_target_property(add_abi_check_target_VERSION ${add_abi_check_target_TARGET} SOVERSION)
    endif()
    if(NOT add_abi_check_target_VERSION)
        message(FATAL_ERROR "No `VERSION` parameter has given and no `SOVERSION` property has set on target `${add_abi_check_target_TARGET}`")
    endif()

    if(NOT add_abi_check_target_HEADERS)
        set(add_abi_check_target_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Get sources list of the given target
    # NOTE Sometimes (if object library has used for example), this property is empty
    # or incomplete...
    if(NOT add_abi_check_target_SOURCES)
        get_target_property(add_abi_check_target_SOURCES ${add_abi_check_target_TARGET} SOURCES)
    endif()

    set(
        add_abi_check_target_XML_DESCRIPTOR
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}.${add_abi_check_target_VERSION}.xml"
      )

    # Set expected ABI dump filename
    # ALERT There is no way to get target filename at this point!
    # So, lets guess a name...
    # TODO Provide a way to override it via parameter.
    set(_libname "lib${add_abi_check_target_TARGET}")
    set(add_abi_check_target_DUMP_FILE "${add_abi_check_target_ABI_CHECKER_DIR}/${_libname}_${add_abi_check_target_VERSION}.abi.tar.gz")
    set(add_abi_check_target_LATEST_DUMP_FILE "${add_abi_check_target_ABI_CHECKER_DIR}/${_libname}_last.abi.tar.gz")

    set(add_abi_check_target_COMMON_CMAKE_CODE "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-abi-common.cmake")
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
        "${add_abi_check_target_COMMON_CMAKE_CODE}"
        @ONLY
      )

    # Bind XML preparation to the target's post-build event, so it'll be updated
    # every time the target has changed
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-check-prepare-xml.cmake.in"
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-prepare-xml.cmake"
        @ONLY
      )
    add_custom_command(
        TARGET ${add_abi_check_target_TARGET}
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -P "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-prepare-xml.cmake"
        BYPRODUCTS "${add_abi_check_target_XML_DESCRIPTOR}"
        COMMENT "Generate XML descriptor for `${add_abi_check_target_TARGET}` to check ABI compatibility"
      )

    # Add target to produce ABI dump
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-make.cmake.in"
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-make-abi-dump.cmake"
        @ONLY
      )
    add_custom_command(
        OUTPUT "${add_abi_check_target_DUMP_FILE}"
        COMMAND "${CMAKE_COMMAND}" -P "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-make-abi-dump.cmake"
        COMMENT "Generate ABI dump for `${add_abi_check_target_TARGET}`"
        MAIN_DEPENDENCY "${add_abi_check_target_XML_DESCRIPTOR}"
        DEPENDS
            "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-make.cmake.in"
            "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-make-abi-dump.cmake"
      )

    # Add target to upload a dump to Artifactory
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-update.cmake.in"
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-update-abi-dump.cmake"
        @ONLY
      )
    add_custom_target(
        ${add_abi_check_target_TARGET}-update-abi-dump
        COMMAND "${CMAKE_COMMAND}" -P "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-update-abi-dump.cmake"
        COMMENT "Updating latest ABI dump for `${add_abi_check_target_TARGET}`"
        DEPENDS
            "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-update.cmake.in"
            "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-update-abi-dump.cmake"
            "${add_abi_check_target_DUMP_FILE}"
      )

    # Add target to get the latest ABI dump
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-get-latest.cmake.in"
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-get-latest-abi-dump.cmake"
        @ONLY
      )
    add_custom_command(
        OUTPUT "${add_abi_check_target_LATEST_DUMP_FILE}"
        COMMAND "${CMAKE_COMMAND}" -P "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-get-latest-abi-dump.cmake"
        COMMENT "Getting latest ABI dump for `${add_abi_check_target_TARGET}`"
        DEPENDS
            "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/artifactory_get_dumps.aql.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-get-latest.cmake.in"
            "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-get-latest-abi-dump.cmake"
      )

    # Add target to do checking
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-check.cmake.in"
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-abi-check.cmake"
        @ONLY
      )
    add_custom_target(
        ${add_abi_check_target_TARGET}-abi-check
        COMMAND "${CMAKE_COMMAND}" -P "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-abi-check.cmake"
        COMMENT "Checking current version ${add_abi_check_target_VERSION} of `${add_abi_check_target_TARGET}` against latest ABI dump"
        BYPRODUCTS "${add_abi_check_target_ABI_CHECKER_DIR}/report.html"
        DEPENDS
            "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-check.cmake.in"
            "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-abi-check.cmake"
            "${add_abi_check_target_XML_DESCRIPTOR}"
            "${add_abi_check_target_DUMP_FILE}"
            "${add_abi_check_target_LATEST_DUMP_FILE}"
            "${add_abi_check_target_TARGET}"
      )
    add_dependencies(${add_abi_check_target_TARGET}-abi-check ${add_abi_check_target_TARGET})

    include("${_ADD_ABI_CHECK_TARGET_LIST_DIR}/TeamCityIntegration.cmake")
    is_running_under_teamcity(_under_tc)
    if(NOT _under_tc)
        include("${_ADD_ABI_CHECK_TARGET_LIST_DIR}/AddOpenTarget.cmake")
        add_open_target(
            ${add_abi_check_target_TARGET}-show-abi-check-report
            "${add_abi_check_target_ABI_CHECKER_DIR}/report.html"
            DEPENDS
                "${add_abi_check_target_ABI_CHECKER_DIR}/report.html"
          )
        add_dependencies(${add_abi_check_target_TARGET}-show-abi-check-report ${add_abi_check_target_TARGET}-abi-check)
    endif()

endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: AddABICheckTarget.cmake
# X-Chewy-Version: 3.0
# X-Chewy-Description: Use `abi-compliance-checker` from CMake build
# X-Chewy-AddonFile: AddABICheckTarget.cmake.in
# X-Chewy-AddonFile: AddOpenTarget.cmake
# X-Chewy-AddonFile: Artifactory.cmake
# X-Chewy-AddonFile: TeamCityIntegration.cmake
# X-Chewy-AddonFile: abi-check.cmake.in
# X-Chewy-AddonFile: abi-check-prepare-xml.cmake.in
# X-Chewy-AddonFile: abi-dump-get-latest.cmake.in
# X-Chewy-AddonFile: abi-dump-make.cmake.in
# X-Chewy-AddonFile: abi-dump-update.cmake.in
# X-Chewy-AddonFile: artifactory_get_dumps.aql
# X-Chewy-AddonFile: library-abi.xml.in
