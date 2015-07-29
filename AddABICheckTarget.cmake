# - Add targets to update ABI dump and check ABI compatibility
#
# TODO Docs
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
# Copyright 2015 by Alex Turbov <i.zaufi@gmail.com>
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

find_program(ABI_COMPIANCE_CHECKER_EXECUABLE abi-compliance-checker)
if(ABI_COMPIANCE_CHECKER_EXECUABLE)
    message(STATUS "Found abi-compliance-checker: ${ABI_COMPIANCE_CHECKER_EXECUABLE}")
else()
    message(STATUS "WARNING: `abi-compliance-checker` not found. Won't check ABI compliance...")
endif()

find_program(JQ_EXECUABLE jq)
if(JQ_EXECUABLE)
    message(STATUS "Found jq: ${JQ_EXECUABLE}")
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
    set(one_value_args TARGET DIRECTORY LIBRARY OUTPUT VERSION)
    set(multi_value_args HEADERS SKIP_HEADERS)
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
    if(NOT JQ_EXECUABLE)
        if(add_abi_check_target_DEBUG)
            message(STATUS "  [add_abi_check_target] `jq` wasn't found. Exiting...")
        endif()
        return()
    endif()

    # `TARGET` is a mandatory option
    if(NOT TARGET ${add_abi_check_target_TARGET})
        message(FATAL_ERROR "`${add_abi_check_target_TARGET}' is not a target name")
    endif()
    # TODO Make sure target is a library?

    # Prepare target properties for future including
    set(add_abi_check_target_TARGET_PROPS_FILE "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-abi-check-target-properties.cmake")
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

    if(NOT add_abi_check_target_OUTPUT)
        set(add_abi_check_target_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}.${add_abi_check_target_VERSION}.xml")
    endif()

    if(NOT add_abi_check_target_HEADERS)
        set(add_abi_check_target_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Get sources list of the given target
    get_target_property(add_abi_check_target_SOURCES ${add_abi_check_target_TARGET} SOURCES)

    set(add_abi_check_target_COMMON_CMAKE_CODE "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-abi-common.cmake")
    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
        "${add_abi_check_target_COMMON_CMAKE_CODE}"
        @ONLY
      )

    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-check.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-abi-check.cmake"
        @ONLY
      )

    configure_file(
        "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-update.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-update-abi-dump.cmake"
        @ONLY
      )

    add_custom_target(
        ${add_abi_check_target_TARGET}-abi-check
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-abi-check.cmake"
        COMMENT "Checking current version ${add_abi_check_target_VERSION} of `${add_abi_check_target_TARGET}` against latest ABI dump"
        DEPENDS
            "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-check.cmake.in"
            "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-abi-check.cmake"
      )
    add_dependencies(${add_abi_check_target_TARGET}-abi-check ${add_abi_check_target_TARGET})

    add_custom_target(
        ${add_abi_check_target_TARGET}-update-abi-dump
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-update-abi-dump.cmake"
        COMMENT "Updating latest ABI dump for `${add_abi_check_target_TARGET}`"
        DEPENDS
            "${_ADD_ABI_CHECK_TARGET_LIST_FILE}.in"
            "${_ADD_ABI_CHECK_TARGET_LIST_DIR}/abi-dump-update.cmake.in"
            "${CMAKE_CURRENT_BINARY_DIR}/${add_abi_check_target_TARGET}-update-abi-dump.cmake"
      )
    add_dependencies(${add_abi_check_target_TARGET}-update-abi-dump ${add_abi_check_target_TARGET})
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: AddABICheckTarget.cmake
# X-Chewy-Version: 1.1
# X-Chewy-Description: Use `abi-compliance-checker` from CMake build
# X-Chewy-AddonFile: AddABICheckTarget.cmake.in
# X-Chewy-AddonFile: TeamCityIntegration.cmake
# X-Chewy-AddonFile: abi-check.cmake.in
# X-Chewy-AddonFile: abi-dump-update.cmake.in
# X-Chewy-AddonFile: library-abi.xml.in
