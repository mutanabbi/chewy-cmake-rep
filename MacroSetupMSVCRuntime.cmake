# - Configure MSVC runtime library compiler options
# Configure corresponding compiler options to use static or dynamic MSVC runtime
#
# Synopsis:
#   setup_msvc_runtime(<STATIC|SHARED> [VARIABLES <LIST-OF-VARS-TO-FIX>])
#
# List of variables w/ compiler options always includes the follwing:
#     CMAKE_C_FLAGS_DEBUG
#     CMAKE_C_FLAGS_MINSIZEREL
#     CMAKE_C_FLAGS_RELEASE
#     CMAKE_C_FLAGS_RELWITHDEBINFO
#     CMAKE_CXX_FLAGS_DEBUG
#     CMAKE_CXX_FLAGS_MINSIZEREL
#     CMAKE_CXX_FLAGS_RELEASE
#     CMAKE_CXX_FLAGS_RELWITHDEBINFO
#
# You can add others if there is some other "profile" has configured.
#

#=============================================================================
# Copyright 2014 by Alex Turbov <i.zaufi@gmail.com>
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

if(NOT WIN32 OR NOT MSVC)
    message(FATAL_ERROR "No need to use setup_msvc_runtime for non Windows/MSVC")
endif()

macro(setup_msvc_runtime runtime_type)
    set(options)
    set(one_value_args)
    set(multi_value_args VARIABLES)
    cmake_parse_arguments(setup_msvc_runtime "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    string(TOUPPER "${runtime_type}" _setup_msvc_runtime_type)
    if(_setup_msvc_runtime_type STREQUAL "SHARED")
        set(_setup_msvc_runtime_what "/MT")
        set(_setup_msvc_runtime_repl "/MD")
        message(STATUS "Forcing use of dynamically-linked runtime")
    elseif(_setup_msvc_runtime_type STREQUAL "STATIC")
        set(_setup_msvc_runtime_what "/MD")
        set(_setup_msvc_runtime_repl "/MT")
        message(STATUS "Forcing use of statically-linked runtime")
    else()
        message(FATAL_ERROR "Invalid RUNTIME option value ${setup_msvc_runtime_RUNTIME}")
    endif()

    # Add predefined profiles
    list(
        APPEND setup_msvc_runtime_VARIABLES
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_MINSIZEREL
            CMAKE_C_FLAGS_RELEASE
            CMAKE_C_FLAGS_RELWITHDEBINFO
            CMAKE_CXX_FLAGS_DEBUG
            CMAKE_CXX_FLAGS_MINSIZEREL
            CMAKE_CXX_FLAGS_RELEASE
            CMAKE_CXX_FLAGS_RELWITHDEBINFO
      )

    foreach(variable ${setup_msvc_runtime_VARIABLES})
        if(${variable} MATCHES "${_setup_msvc_runtime_what}")
            string(
              REGEX REPLACE
                    "${_setup_msvc_runtime_what}"
                    "${_setup_msvc_runtime_repl}"
                ${variable}
                "${${variable}}"
              )
        endif()
    endforeach()
endmacro()

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: MacroSetupMSVCRuntime.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Configure MSVC runtime library compiler options
