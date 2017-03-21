# - Add targets to update ABI dump and check ABI compatibility
#
# TODO Docs
# TODO Make it possible to store ABI dumps at arbitrary service
# TODO Need to review dependencies, so changing `CMakeLists.txt` would rebuild an XML descriptor
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

if(NOT ADD_ABI_CHECK_TARGET_DEBUG AND "$ENV{ADD_ABI_CHECK_TARGET_DEBUG}")
    set(ADD_ABI_CHECK_TARGET_DEBUG ON)
endif()

if(ABI_CHECK_DEFAULT_REPO)
    set(add_abi_check_target_ARTIFACTORY_REPO "${ABI_CHECK_DEFAULT_REPO}")
elseif(UNIX)
    message(STATUS "WARNING: No `ABI_CHECK_DEFAULT_REPO` has set/given. Checking ABI compliance wouldn't be possible.")
endif()

if(UNIX)
    find_program(
        ABI_COMPLIANCE_CHECKER_EXECUTABLE abi-compliance-checker
        DOC "path to ABI compliance checker executable"
      )
    mark_as_advanced(ABI_COMPLIANCE_CHECKER_EXECUTABLE)
    if(ABI_COMPLIANCE_CHECKER_EXECUTABLE)
        message(STATUS "Found abi-compliance-checker: ${ABI_COMPLIANCE_CHECKER_EXECUTABLE}")
    else()
        message(STATUS "WARNING: `abi-compliance-checker` not found. Won't check ABI compliance...")
    endif()

    find_program(
        JQ_EXECUTABLE jq
        DOC "path to command-line JSON processor executable"
      )
    mark_as_advanced(JQ_EXECUTABLE)
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

    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

    include("${_ADD_ABI_CHECK_TARGET_LIST_DIR}/AddOpenTarget.cmake")
    include("${_ADD_ABI_CHECK_TARGET_LIST_DIR}/GetDistribInfo.cmake")
    include("${_ADD_ABI_CHECK_TARGET_LIST_DIR}/TeamCityIntegration.cmake")

    # NOTE A "global" target to check ABI of requested libraries
    # (i.e. targets for which `add_abi_check_target()` was called)
    add_custom_target(abi-check)
endif()

function(_abi_check_target_debug_msg msg)
    if(add_abi_check_target_DEBUG)
        message(STATUS "[add_abi_check_target] ${msg}")
    endif()
endfunction()

function(_collect_include_paths_recursively RESULT_VAR STATE_VAR)
    set(_state "${${STATE_VAR}}")
    _abi_check_target_debug_msg("libs to process: ${ARGN}")
    _abi_check_target_debug_msg("seen libs on entry: ${_state}")

    foreach(_l IN LISTS ARGN)
        if(TARGET ${_l} AND NOT ${_l} IN_LIST _state)
            list(APPEND _state "${_l}")
            get_target_property(_is_imported ${_l} IMPORTED)
            if(_is_imported)
                get_target_property(_includes ${_l} INTERFACE_INCLUDE_DIRECTORIES)
                if(_includes)
                    list(APPEND _include_paths "${_includes}")
                    list(REMOVE_DUPLICATES _include_paths)
                    _abi_check_target_debug_msg("add include path for imported target `${_l}`: ${_includes}")
                endif()
                get_target_property(_libs ${_l} INTERFACE_LINK_LIBRARIES)
                if(_libs)
                    _abi_check_target_debug_msg("got a list of depenencies for `${_l}`: ${_libs}")
                    _collect_include_paths_recursively(_more_include_paths _state ${_libs})
                    if(_more_include_paths)
                        list(APPEND _include_paths "${_more_include_paths}")
                        list(REMOVE_DUPLICATES _include_paths)
                    endif()
                endif()
            endif()
        endif()
    endforeach()

    set(${STATE_VAR} "${_state}" PARENT_SCOPE)
    set(${RESULT_VAR} "${_include_paths}" PARENT_SCOPE)

    _abi_check_target_debug_msg("seen libs on exit: ${_state}")
endfunction()

function(add_abi_check_target TGT2CHECK)
    set(options DEBUG)
    set(one_value_args ABI_CHECK_EXTRA_OPTIONS DIRECTORY VERSION)
    set(multi_value_args HEADERS SKIP_HEADERS SOURCES)
    cmake_parse_arguments(add_abi_check_target "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    # Enable debug mode if it was requested via CMake CLI or environment
    if(NOT add_abi_check_target_DEBUG AND ADD_ABI_CHECK_TARGET_DEBUG)
        set(add_abi_check_target_DEBUG ON)
    endif()

    # `abi-compliance-checker` needs GCC
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR WIN32)
        _abi_check_target_debug_msg("CXX compiler is not GCC for *nix. Exiting...")
        return()
    endif()

    # Check that `jq` is here...
    if(NOT JQ_EXECUTABLE)
        _abi_check_target_debug_msg("`jq` wasn't found. Exiting...")
        return()
    endif()

    if(ABI_CHECK_DEFAULT_REPO)
        set(add_abi_check_target_ARTIFACTORY_REPO "${ABI_CHECK_DEFAULT_REPO}")
    else()
        _abi_check_target_debug_msg("`ABI_CHECK_DEFAULT_REPO` not set. Exiting...")
        return()
    endif()

    # `TARGET` is a mandatory argument
    if(NOT TGT2CHECK)
        message(FATAL_ERROR "No target argument given")
    endif()
    set(add_abi_check_target_TARGET "${TGT2CHECK}")
    if(NOT TARGET "${add_abi_check_target_TARGET}")
        message(FATAL_ERROR "`${add_abi_check_target_TARGET}' is not a target name")
    endif()
    get_target_property(_is_imported "${add_abi_check_target_TARGET}" IMPORTED)
    if(_is_imported)
        message(FATAL_ERROR "Target `${add_abi_check_target_TARGET}' should not be imported one")
    endif()
    get_target_property(_target_type "${add_abi_check_target_TARGET}" TYPE)
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
    # ATTENTION At the very first time, a file generated is not immediately flushed!
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
        get_target_property(add_abi_check_target_VERSION ${add_abi_check_target_TARGET} VERSION)
    endif()
    if(NOT add_abi_check_target_VERSION)
        get_target_property(add_abi_check_target_VERSION ${add_abi_check_target_TARGET} SOVERSION)
    endif()
    if(NOT add_abi_check_target_VERSION)
        message(
            FATAL_ERROR
            "No `VERSION` parameter has given and no `VERSION` or `SOVERSION` property has been set on target `${add_abi_check_target_TARGET}`"
          )
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

    # Gather include paths of imported dependencies
    get_target_property(_link_libraries ${add_abi_check_target_TARGET} LINK_LIBRARIES)
    _collect_include_paths_recursively(add_abi_check_target_INCLUDE_PATHS _seen_libs ${_link_libraries})

    # Distribution info needed to distinct ABI dumps in the repo
    set(add_abi_check_target_DISTRIB "${DISTRIB_ID}")
    if(DISTRIB_VERSION_MAJOR)
        string(APPEND add_abi_check_target_DISTRIB "-${DISTRIB_VERSION_MAJOR}")
    endif()
    if(DISTRIB_ARCH)
        string(APPEND add_abi_check_target_DISTRIB "-${DISTRIB_ARCH}")
    endif()

    set(
        add_abi_check_target_XML_DESCRIPTOR
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}.${add_abi_check_target_VERSION}.xml"
      )

    # Set expected ABI dump filenames
    # ALERT There is no way to get target filename at this point!
    # So, lets use a target name...
    set(
        add_abi_check_target_DUMP_FILE
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}_${add_abi_check_target_VERSION}.abi.tar.gz"
      )
    set(
        add_abi_check_target_LATEST_DUMP_FILE
        "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}_last.abi.tar.gz"
      )

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
        COMMENT "Generating XML descriptor for `${add_abi_check_target_TARGET}` to check ABI compatibility"
        DEPENDS
            "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt"
            "${add_abi_check_target_ABI_CHECKER_DIR}/${add_abi_check_target_TARGET}-prepare-xml.cmake"
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
        COMMENT "Generating ABI dump for `${add_abi_check_target_TARGET}`"
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
            "${add_abi_check_target_LATEST_DUMP_FILE}"
      )
    add_dependencies(${add_abi_check_target_TARGET}-abi-check ${add_abi_check_target_TARGET})
    add_dependencies(abi-check ${add_abi_check_target_TARGET}-abi-check)

    is_running_under_teamcity(_under_tc)
    # ATTENTION `add_open_target` won't add any target if `xdg-open` is not available!
    if(NOT _under_tc AND XDG_OPEN_EXECUTABLE)
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
# X-Chewy-Version: 3.6
# X-Chewy-Description: Use `abi-compliance-checker` from CMake build
# X-Chewy-AddonFile: AddABICheckTarget.cmake.in
# X-Chewy-AddonFile: AddOpenTarget.cmake
# X-Chewy-AddonFile: Artifactory.cmake
# X-Chewy-AddonFile: GetDistribInfo.cmake
# X-Chewy-AddonFile: TeamCityIntegration.cmake
# X-Chewy-AddonFile: abi-check.cmake.in
# X-Chewy-AddonFile: abi-check-prepare-xml.cmake.in
# X-Chewy-AddonFile: abi-dump-get-latest.cmake.in
# X-Chewy-AddonFile: abi-dump-make.cmake.in
# X-Chewy-AddonFile: abi-dump-update.cmake.in
# X-Chewy-AddonFile: artifactory_get_dumps.aql
# X-Chewy-AddonFile: library-abi.xml.in
