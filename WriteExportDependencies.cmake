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
    set(options)
    set(one_value_args TARGET FILE_PREFIX EXPORT_OVERRIDE)
    set(multi_value_args)
    cmake_parse_arguments(_WED "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    if(NOT _WED_FILE_PREFIX)
        set(_WED_FILE_PREFIX "${CMAKE_PROJECT_NAME}")
    endif()

    # Check if EXPORT_NAME override is used
    if(_WED_TARGET AND TARGET ${_WED_TARGET})
        if(_WED_EXPORT_OVERRIDE)
            set(_wed_export_filename_part ${_WED_EXPORT_OVERRIDE})
        else()
            get_target_property(_wed_export_filename_part ${_WED_TARGET} EXPORT_NAME)
        endif()
        get_target_property(_wed_link_libraries ${_WED_TARGET} INTERFACE_LINK_LIBRARIES)
    else()
        message(FATAL_ERROR "TARGET parameter is mandatory when call write_export_dependencies()")
    endif()

    ecm_debug("Write export dependencies for target `${_WED_TARGET}`")
    ecm_debug_indent()
    # Form `internal` (i.e. build by this project) and `external` dependencies list
    set(_WED_EXTERNAL_DEPS)
    set(_WED_INTERNAL_DEPS)
    foreach(_d ${_wed_link_libraries})
        if(_d MATCHES "^.*::.*$")
            string(REGEX REPLACE "^(.*)::.*$" "\\1" _wed_vendor "${_d}")
            string(REGEX REPLACE "^.*::(.*)$" "\\1" _wed_comp "${_d}")
            string(TOUPPER "${_wed_vendor}" _wed_vendor_up)
            ecm_debug("found imported library: ${_d}")

            if(NOT ${_wed_vendor} IN_LIST _WED_EXTERNAL_DEPS)
                list(APPEND _WED_EXTERNAL_DEPS ${_wed_vendor})
                ecm_debug("add `${_wed_vendor}` to the list of package names to find")
            endif()
            list(APPEND _WED_EXTERNAL_${_wed_vendor_up}_COMPONENTS ${_wed_comp})
            ecm_debug("add `${_wed_comp}` to the list of components of `${_wed_vendor}` package")

            if(NOT DEFINED _WED_EXTERNAL_${_wed_vendor_up}_VERSION)
                if(DEFINED ${_wed_vendor_up}_VERSION)
                    set(_WED_EXTERNAL_${_wed_vendor_up}_VERSION ${${_wed_vendor_up}_VERSION})
                elseif(DEFINED ${_wed_vendor}_VERSION)
                    set(_WED_EXTERNAL_${_wed_vendor_up}_VERSION ${${_wed_vendor}_VERSION})
                endif()
                if(DEFINED _WED_EXTERNAL_${_wed_vendor_up}_VERSION)
                    ecm_debug("would require version ${_WED_EXTERNAL_${_wed_vendor_up}_VERSION} of `${_wed_vendor}` package")
                endif()
            endif()
        else()
            ecm_debug("found library: ${_d}")
            list(APPEND _WED_INTERNAL_DEPS "${_d}")
        endif()
    endforeach()
    ecm_debug_unindent()

    set(_WED_SETUP_VARIABLES)
    foreach(_wed_vendor ${_WED_EXTERNAL_DEPS})
        string(TOUPPER "${_wed_vendor}" _wed_vendor_up)
        if(DEFINED _WED_EXTERNAL_${_wed_vendor_up}_VERSION)
            set(_WED_SETUP_VARIABLES "${_WED_SETUP_VARIABLES}\nset(_WED_EXTERNAL_${_wed_vendor_up}_VERSION ${_WED_EXTERNAL_${_wed_vendor_up}_VERSION})")
        endif()
        if(DEFINED _WED_EXTERNAL_${_wed_vendor_up}_COMPONENTS)
            set(_WED_SETUP_VARIABLES "${_WED_SETUP_VARIABLES}\nset(_WED_EXTERNAL_${_wed_vendor_up}_COMPONENTS ${_WED_EXTERNAL_${_wed_vendor_up}_COMPONENTS})")
        endif()
    endforeach()

    # Produce dependencies file only if there some dependencies provided
    set(_wed_input_file "${_WED_BASE_DIR}/export-dependencies.cmake.in")
    set(
        _wed_output_file
        "${CMAKE_CURRENT_BINARY_DIR}/${_WED_FILE_PREFIX}-${_wed_export_filename_part}-dependencies.cmake"
      )
    if(_WED_INTERNAL_DEPS OR _WED_EXTERNAL_DEPS)
        configure_file("${_wed_input_file}" "${_wed_output_file}" @ONLY)
    else()
        message(FATAL_ERROR "DEPENDENCIES parameter is mandatory when call write_export_dependencies()")
    endif()
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: WriteExportDependencies.cmake
# X-Chewy-Version: 2.0
# X-Chewy-Description: Write an export dependencies file
# X-Chewy-AddonFile: export-dependencies.cmake.in
