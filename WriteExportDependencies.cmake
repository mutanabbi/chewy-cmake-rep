# - Write an export dependencies file
#
# TODO More elaborate docs
#

#=============================================================================
# Copyright 2014-2015 by Alex Turbov <i.zaufi@gmail.com>
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

set(_WED_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(write_export_dependencies)
    set(options APPEND)
    set(one_value_args TARGET FILE_PREFIX DEPENDED_FILE_PREFIX EXPORT_OVERRIDE)
    set(multi_value_args DEPENDENCIES)
    cmake_parse_arguments(_WED "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT _WED_FILE_PREFIX)
        set(_WED_FILE_PREFIX "${CMAKE_PROJECT_NAME}")
    endif()

    if(NOT _WED_DEPENDED_FILE_PREFIX)
        set(_WED_DEPENDED_FILE_PREFIX "${_WED_FILE_PREFIX}")
    endif()

    # Check if EXPORT_NAME override is used
    if(_WED_EXPORT_OVERRIDE)
        set(_wed_export_filename_part ${_WED_EXPORT_OVERRIDE})
    elseif(_WED_TARGET)                                     # Otherwise, check if TARGET given
        get_target_property(_wed_export_filename_part ${_WED_TARGET} EXPORT_NAME)
    else()
        message(FATAL_ERROR "TARGET or EXPORT_OVERRIDE parameter is mandatory when call write_export_dependencies()")
    endif()

    # Produce dependencies file only if there some dependencies provided
    set(_wed_input_file "${_WED_BASE_DIR}/export-dependencies.cmake.in")
    set(
        _wed_output_file
        "${CMAKE_CURRENT_BINARY_DIR}/${_WED_FILE_PREFIX}-${_wed_export_filename_part}-dependencies.cmake"
      )
    if(_WED_DEPENDENCIES)
        if(NOT _WED_APPEND OR (NOT EXISTS "${_wed_input_file}" AND _WED_APPEND))
            configure_file("${_wed_input_file}" "${_wed_output_file}" @ONLY)
        else()
            configure_file("${_wed_input_file}" "${_wed_output_file}.tmp" @ONLY)
            file(READ "${_wed_output_file}.tmp" _wed_generated_content)
            file(APPEND "${_wed_output_file}" "${_wed_generated_content}")
            file(REMOVE "${_wed_output_file}.tmp")
        endif()
    else()
        message(FATAL_ERROR "DEPENDENCIES parameter is mandatory when call write_export_dependencies()")
    endif()
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: WriteExportDependencies.cmake
# X-Chewy-Version: 1.4
# X-Chewy-Description: Write an export dependencies file
# X-Chewy-AddonFile: export-dependencies.cmake.in
