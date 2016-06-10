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
# Copyright 2014-2016 by Alex Turbov <i.zaufi@gmail.com>
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

# Try to find `pkg-config` before
if(NOT WIN32)
    if(ACE_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()
    find_package(PkgConfig ${_pkg_find_quietly})
endif()

function(_ace_debug_msg msg)
    if(ACE_DEBUG)
        message(STATUS "[ACE] ${msg}")
    endif()
endfunction()

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
    _ace_debug_msg("    got pkg-config name to lookup: ${_pkg_module_name}")

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
        _ace_debug_msg("    ${_pkg_module_name} has been found")
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

    # NOTE Allow to override default location(s) via
    # CMake CLI -DACE_INCLUDEDIR=PATH
    list(APPEND _${_ace_comp_up}_include_hints "${ACE_INCLUDEDIR}")
    list(APPEND _${_ace_comp_up}_include_hints "${ACE_ROOT}/include")
    list(APPEND _${_ace_comp_up}_include_hints "${ACE_ROOT}")
    # FHS standard location
    list(APPEND _${_ace_comp_up}_include_hints "/usr/include")
    list(APPEND _${_ace_comp_up}_include_hints "/usr/local/include")
    # Try to use "standard" environment variables
    list(APPEND _${_ace_comp_up}_include_hints "$ENV{ACE_ROOT}/include")
    list(APPEND _${_ace_comp_up}_include_hints "$ENV{ACE_ROOT}")
    # Windows specific "standard" (?) location
    list(APPEND _${_ace_comp_up}_include_hints "$ENV{ProgramW6432}/ACE/include")
    list(APPEND _${_ace_comp_up}_include_hints "$ENV{ProgramFiles}/ACE/include")
    _ace_debug_msg("    include hints: ${_${_ace_comp_up}_include_hints}")
    find_path(
        ACE_${_ace_comp_up}_INCLUDE_DIR
        NAMES ${_ace_manual_find_headers}
        PATHS ${_${_ace_comp_up}_include_hints}
      )
    mark_as_advanced(ACE_${_ace_comp_up}_INCLUDE_DIR)
    _ace_debug_msg("    after searching include dir: ${ACE_${_ace_comp_up}_INCLUDE_DIR}")

    # Try to find a libraries then
    _ace_find_component_via_cmake_get_libs(${_ace_comp})
    # NOTE Allow to override default location(s) via
    # CMake CLI -DACE_LIB_DIR=PATH
    list(APPEND _${_ace_comp_up}_lib_hints "${ACE_LIBDIR}")
    list(APPEND _${_ace_comp_up}_lib_hints "${ACE_ROOT}/lib")
    # FHS standard location
    list(APPEND _${_ace_comp_up}_lib_hints "/usr/lib")
    list(APPEND _${_ace_comp_up}_lib_hints "/usr/local/lib")
    # Try to use "standard" environment variables
    list(APPEND _${_ace_comp_up}_lib_hints "$ENV{ACE_ROOT}/lib")
    list(APPEND _${_ace_comp_up}_lib_hints "$ENV{ACE_ROOT}")
    # Windows specific "standard" (?) location
    list(APPEND _${_ace_comp_up}_lib_hints "$ENV{ProgramFiles}/ACE/lib/")
    _ace_debug_msg("    lib hints: ${_${_ace_comp_up}_lib_hints}")
    find_library(
        ACE_${_ace_comp_up}_LIBRARIES
        NAMES ${_ace_manual_find_libraries}
        PATHS ${_${_ace_comp_up}_lib_hints}
      )
    mark_as_advanced(ACE_${_ace_comp_up}_LIBRARIES)
    _ace_debug_msg("    after searching lib dir: ${ACE_${_ace_comp_up}_LIBRARIES}")
    if(ACE_${_ace_comp_up}_LIBRARIES)
        set(ACE_${_ace_comp_up}_FOUND _FOUND)
    endif()
endmacro()

# Try to find a given component
macro(_ace_find_component _ace_comp)
    if(WIN32)
        _ace_debug_msg("    Win32 detected, do not even try `pkg-config`...")
        _ace_find_component_via_cmake(${_ace_comp})
    else()
        _ace_debug_msg("    *NIX detected, try `pkg-config`...")
        _ace_find_component_via_pkg_config(${_ace_comp})
        string(TOUPPER "${_ace_comp}" _ace_comp_up)
        if(NOT ACE_${_ace_comp_up}_FOUND)
            _ace_debug_msg("    fallback to manual search via cmake...")
            # Trying "manual" way...
            _ace_find_component_via_cmake(${_ace_comp})
        endif()
    endif()
endmacro()

# Check if already in cache
# NOTE Feel free to check/change/add any other vars
if(NOT ACE_LIBRARIES)
    _ace_debug_msg("ACE_LIBRARIES is not set... Ok, will find!")

    # If user provides particular component(s) to find?
    if(NOT ACE_FIND_COMPONENTS)
        # No! Just find ACE library...
        set(ACE_FIND_COMPONENTS "ace")
        _ace_debug_msg("No COMPONENTS has been specified... setting to `ace`")
    endif()
    _ace_debug_msg("Going to find: ${ACE_FIND_COMPONENTS}")

    # Look for components
    set(ACE_FOUND TRUE)
    _ace_debug_msg("ACE_FOUND=${ACE_FOUND}")
    foreach(_ace_comp ${ACE_FIND_COMPONENTS})
        _ace_debug_msg("  checking component: ${_ace_comp}")
        string(TOUPPER "${_ace_comp}" _ace_comp_up)
        # Going to find this particular component
        _ace_find_component(${_ace_comp})
        # Check if component is mandatory
        # Did we find smth?
        if(ACE_${_ace_comp_up}_FOUND)
            _ace_debug_msg("  found component: ${_ace_comp}")
            # Yep!
            foreach(l ${ACE_${_ace_comp_up}_LIBRARY_DIRS})
                list(APPEND ACE_LIBRARIES -L${l})
            endforeach()
            list(APPEND ACE_LIBRARIES ${ACE_${_ace_comp_up}_LIBRARIES} ${ACE_${_ace_comp_up}_LIBRARIES})
            list(APPEND ACE_INCLUDE_DIRS ${ACE_${_ace_comp_up}_INCLUDE_DIR})
        else()
            _ace_debug_msg("  component not found: ${_ace_comp}")
            # No! Check if that component is mandatory
            if(ACE_FIND_REQUIRED_${_ace_comp} AND ACE_FOUND)
                # Set whole package FOUND to false
                set(ACE_FOUND FALSE)
                _ace_debug_msg("  component is requered, so set ACE_FOUND=${ACE_FOUND}")
            endif()
        endif()
    endforeach()

    # Try to get ACE version if headers/libs are (seem) Ok
    if(ACE_FOUND)
        _ace_debug_msg("Getting ACE version from compiled sample")
        # Try to compile sample test which would (try to) output the ACE version
        try_run(
            _ace_get_version_run_result
            _ace_get_version_compile_result
            ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}/ace_get_version.cpp
            CMAKE_FLAGS
                -DINCLUDE_DIRECTORIES:STRING=${ACE_INCLUDE_DIRS}
            COMPILE_OUTPUT_VARIABLE _ace_get_version_compile_output
            RUN_OUTPUT_VARIABLE ACE_VERSION
          )
        _ace_debug_msg("ACE version detected: ${ACE_VERSION}")
    endif()

    _ace_debug_msg("F: ACE_INCLUDE_DIRS=${ACE_INCLUDE_DIRS}")
    _ace_debug_msg("F: ACE_LIBRARIES=${ACE_LIBRARIES}")
    _ace_debug_msg("F: ACE_DEFINITIONS=${ACE_DEFINITIONS}")

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
# X-Chewy-Version: 1.4
# X-Chewy-Description: Find ACE library (and components) using `pkg-config` if available
# X-Chewy-AddonFile: ace_get_version.cpp
