# - Find ACE library (and components) using `pkg-config` if available
# Search for ACE library (and components) and set the following variables:
#  ACE_FOUND            - is package found
#  ACE_VERSION          - found package version
#  ACE_INCLUDE_DIRS     - dir w/ header files
#  ACE_DEFINITIONS      - other than `-I' compiler flags
#  ACE_LIBRARIES        - libs for dynamic linkage
#
# To give hints to this finder one may use the following settings:
#   ACE_ROOT            - root directory of ACE headers and libraries
#   ACE_INCLUDEDIR      - headers directory
#   ACE_LIBDIR          - libraries directory
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
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

# Setup some options
set(
    ACE_INCLUDEDIR
    "/usr/local/include"
    CACHE PATH
    "ACE framework development headers directory"
  )
set(
    ACE_LIBDIR
    "/usr/local/lib"
    CACHE PATH
    "ACE framework libraries directory"
  )

# Try to find `pkg-config` before
if(NOT WIN32)
    if(ACE_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()
    find_package(PkgConfig ${_pkg_find_quietly})
endif()

# Check _comp_in and set variable provided as "output" parameter
# to corresponding package name (suitable for `pkg-config`)
macro(_ace_component_to_package _pkg_out _comp_in)
    if(${_comp_in} STREQUAL "ace")
        set(${_pkg_out} "ACE")
    elseif(${_comp_in} STREQUAL "ssl")
        set(${_pkg_out} "ACE_SSL")
    endif()
    # TODO Smth else?
endmacro()

# Try to find ACE component via `pkg-config`
macro(_ace_find_component_via_pkg_config _ace_comp)
    string(TOUPPER "${_ace_comp}" _ace_comp_up)

    _ace_component_to_package(_pkg_module_name ${_ace_comp})

    if(ACE_FIND_VERSION)
        if(ACE_FIND_VERSION_EXACT)
            set(_pkg_module_name "${_pkg_module_name}=${ACE_FIND_VERSION}")
        else()
            set(_pkg_module_name "${_pkg_module_name}>=${ACE_FIND_VERSION}")
        endif()
    endif()

    pkg_check_modules(ACE_${_ace_comp_up} ${_pkg_module_name} QUIET)

    # If package has been found
    if(ACE_${_ace_comp_up}_FOUND)
        # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
        # according CMake guide (/usr/share/cmake/Modules/readme.txt)
        set(ACE_${_ace_comp_up}_DEFINITIONS ${ACE_${_ace_comp_up}_CFLAGS_OTHER})
        list(APPEND ACE_DEFINITIONS "${ACE_${_ace_comp_up}_DEFINITIONS}")
    endif()
endmacro()

macro(_ace_find_component_via_cmake_get_headers _ace_comp)
    if("${_ace_comp}" STREQUAL "ace")
        set(_ace_manual_find_headers "ace/ACE.h")
    elseif("${_ace_comp}" STREQUAL "ssl")
        set(_ace_manual_find_headers "ace/SSL/SSL_SOCK.h")
    endif()
    # TODO Smth else?
endmacro()

macro(_ace_find_component_via_cmake_get_libs _ace_comp)
    if("${_ace_comp}" STREQUAL "ace")
        set(_ace_manual_find_libraries "ACE")
    elseif("${_ace_comp}" STREQUAL "ssl")
        set(_ace_manual_find_libraries "ACE_SSL")
    endif()
    # TODO Smth else?
endmacro()

# Try to find ACE component using CMake helpers
macro(_ace_find_component_via_cmake _ace_comp)
    string(TOUPPER "${_ace_comp}" _ace_comp_up)

    # Try to find header first
    _ace_find_component_via_cmake_get_headers(${_ace_comp})
    find_path(
        ACE_${_ace_comp_up}_INCLUDE_DIR
        NAMES ${_ace_manual_find_headers}
        PATHS
            # NOTE Allow to override default location(s) via
            # CMake CLI -DACE_INCLUDEDIR=PATH
            ${ACE_INCLUDEDIR}
            # FHS standard location
            /usr/include
            # Try to use "standard" environment variables
            $ENV{ACE_ROOT}/include
            $ENV{ACE_ROOT}
            # Windows specific "standard" (?) location
            $ENV{ProgramFiles}/ACE/*/include
      )
    mark_as_advanced(ACE_${_ace_comp_up}_INCLUDE_DIR)

    # Try to find a libraries then
    _ace_find_component_via_cmake_get_libs(${_ace_comp})
    find_library(
        ACE_${_ace_comp_up}_LIBRARIES
        NAMES ${_ace_manual_find_libraries}
        PATHS
            # NOTE Allow to override default location(s) via
            # CMake CLI -DACE_LIB_DIR=PATH
            ${ACE_LIBDIR}
            # FHS standard location
            /usr/lib
            # Try to use "standard" environment variables
            $ENV{ACE_ROOT}/lib
            $ENV{ACE_ROOT}
            # Windows specific "standard" (?) location
            $ENV{ProgramFiles}/ACE/*/lib/
      )
    mark_as_advanced(ACE_${_ace_comp_up}_LIBRARIES)
    if(ACE_${_ace_comp_up}_LIBRARIES)
        set(ACE_${_ace_comp_up}_FOUND _FOUND)
    endif()
endmacro()

# Try to find a given component
macro(_ace_find_component _ace_comp)
    if(WIN32)
        _ace_find_component_via_cmake(${_ace_comp})
    else()
        _ace_find_component_via_pkg_config(${_ace_comp})
    endif()
endmacro()

# Check if already in cache
# NOTE Feel free to check/change/add any other vars
if(NOT ACE_LIBRARIES)

    # If user provides particular component(s) to find?
    if(NOT ACE_FIND_COMPONENTS)
        # No! Just find ACE library...
        set(ACE_FIND_COMPONENTS "ace")
    endif()

    # Look for components
    set(ACE_FOUND TRUE)
    foreach(_ace_comp ${ACE_FIND_COMPONENTS})
        string(TOUPPER "${_ace_comp}" _ace_comp_up)
        # Going to find this particular component
        _ace_find_component(${_ace_comp})
        # Check if component is mandatory
        # Did we find smth?
        if(ACE_${_ace_comp_up}_FOUND)
            # Yep!
            list(APPEND ACE_LIBRARIES ${ACE_${_ace_comp_up}_LIBRARIES})
            list(APPEND ACE_INCLUDE_DIRS ${ACE_${_ace_comp_up}_INCLUDE_DIR})
        else()
            # No! Check if that component is mandatory
            if(ACE_FIND_REQUIRED_${_ace_comp} AND ACE_FOUND)
                # Set whole package FOUND to false
                set(ACE_FOUND FALSE)
            endif()
        endif()
    endforeach()

    # Try to get ACE version if headers/libs are (seem) Ok
    if(ACE_FOUND)
        # Try to compile sample test which would (try to) output the OTL version
        try_run(
            _ace_get_version_run_result
            _ace_get_version_compile_result
            ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}/ace_get_version.cpp
            CMAKE_FLAGS
                -DINCLUDE_DIRECTORIES:STRING=${ACE_INCLUDE_DIRS}
            COMPILE_OUTPUT_VARIABLE _ace_get_version_compile_output
            RUN_OUTPUT_VARIABLE ACE_VERSION
          )
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        ACE
        FOUND_VAR ACE_FOUND
        REQUIRED_VARS ACE_LIBRARIES
        VERSION_VAR ACE_VERSION
      )
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindACE.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find ACE library (and components) using `pkg-config` if available
# X-Chewy-AddonFile: ace_get_version.cpp
