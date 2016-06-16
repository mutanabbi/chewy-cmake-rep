# - Find ACE library (and components) using `pkg-config` if available
# Search for ACE library (and components) and add imported targets for components requested.
#
# To give hints to this finder one may use the following settings:
#   ACE_ROOT             - root directory of ACE headers and libraries
#   ACE_INCLUDEDIR       - headers directory
#   ACE_LIBDIR           - libraries directory (for single configuration generators)
#   ACE_LIBDIR_DEBUG     - debug libraries directory (for multi configuration generators)
#   ACE_LIBDIR_RELEASE   - libraries directory (for multi configuration generators)
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
macro(_ace_find_component_via_cmake _ace_comp _ace_cfg)
    string(TOUPPER "${_ace_comp}" _ace_comp_up)
    string(TOUPPER "${_ace_cfg}" _ace_cfg_up)
    if(_ace_cfg_up)
        set(_ace_cfg_up_sfx "_${_ace_cfg_up}")
    endif()

    _ace_debug_msg("    finding ${_ace_cfg} configuration of ${_ace_comp}")

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
    list(APPEND _${_ace_comp_up}_lib_hints "${ACE_LIBDIR${_ace_cfg_up_sfx}}")
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

macro(_ace_add_import_targets _ace_comp _ace_cfg)
    string(TOUPPER "${_ace_comp}" _ace_comp_up)
    string(TOUPPER "${_ace_cfg}" _ace_cfg_up)
    if(_ace_cfg_up)
        set(_ace_cfg_up_sfx "_${_ace_cfg_up}")
    endif()

    # Do nothing if nothing has found
    if(NOT ACE_${_ace_comp_up}_FOUND)
        _ace_debug_msg("     do not add an imported target! ACE_${_ace_comp_up}_FOUND=${ACE_${_ace_comp_up}_FOUND}")
        return()
    endif()

    if(ACE_AS_STATIC_LIBS)
        _ace_debug_msg("     adding ACE::${_ace_comp} as a static imported library [${_ace_cfg}]")
        if(NOT TARGET ACE::${_ace_comp})
            add_library(ACE::${_ace_comp} STATIC IMPORTED)
        else()
            _ace_debug_msg("     updating ACE::${_ace_comp} [${_ace_cfg}]")
        endif()
        set_property(
            TARGET ACE::${_ace_comp}
            APPEND PROPERTY IMPORTED_CONFIGURATIONS "${_ace_cfg}"
          )
        set_target_properties(
            ACE::${_ace_comp}
            PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
                IMPORTED_LOCATION${_ace_cfg_up_sfx} ${ACE_${_ace_comp_up}_LIBRARIES}
                INTERFACE_COMPILE_DEFINITIONS -DACE_AS_STATIC_LIBS=1
          )
        _ace_debug_msg("     set IMPORTED_LOCATION${_ace_cfg_up_sfx}: ${ACE_${_ace_comp_up}_LIBRARIES}")
    else()
        if(NOT TARGET ACE::${_ace_comp})
            add_library(ACE::${_ace_comp} INTERFACE IMPORTED)
            _ace_debug_msg("     adding ACE::${_ace_comp} as shared imported library [${_ace_cfg}]")
        else()
            _ace_debug_msg("     updating ACE::${_ace_comp} [${_ace_cfg}]")
        endif()
        _ace_debug_msg("     set INTERFACE_LINK_LIBRARIES${_ace_cfg_up_sfx}: ${ACE_${_ace_comp_up}_LIBRARIES}")
        set_target_properties(
            ACE::${_ace_comp}
            PROPERTIES
                INTERFACE_LINK_LIBRARIES "${ACE_${_ace_comp_up}_LIBRARIES}"
          )
    endif()

    set_property(
        TARGET ACE::${_ace_comp}
        APPEND PROPERTY INTERFACE_LINK_LIBRARIES Threads::Threads
        )

    if(ACE_${_ace_comp_up}_INCLUDE_DIR)
        set_target_properties(
            ACE::${_ace_comp}
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${ACE_${_ace_comp_up}_INCLUDE_DIR}"
          )
    endif()
endmacro()

# Try to find a given component
macro(_ace_find_component _ace_comp)
    if(WIN32)
        _ace_debug_msg("    Win32 detected, do not even try `pkg-config`...")
        foreach(_cfg ${_ace_find_configurations})
            _ace_find_component_via_cmake(${_ace_comp} ${_cfg})
            _ace_add_import_targets(${_ace_comp} ${_cfg})
        endforeach()
    else()
        _ace_debug_msg("    *NIX detected, try `pkg-config`...")
        _ace_find_component_via_pkg_config(${_ace_comp})
        _ace_add_import_targets(${_ace_comp} ${_ace_find_configurations})
        string(TOUPPER "${_ace_comp}" _ace_comp_up)
        if(NOT ACE_${_ace_comp_up}_FOUND)
            _ace_debug_msg("    fallback to manual search via cmake...")
            # Trying "manual" way...
            _ace_find_component_via_cmake(${_ace_comp} "")
            _ace_add_import_targets(${_ace_comp} ${_ace_find_configurations})
        endif()
    endif()
endmacro()

# Try to find `pkg-config` before
if(NOT WIN32)
    if(ACE_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()
    find_package(PkgConfig ${_pkg_find_quietly})
endif()

# Check what king of generator is in use
if(CMAKE_CONFIGURATION_TYPES)
    _ace_debug_msg("Multi configuration generator: ${CMAKE_CONFIGURATION_TYPES}")
    set(_ace_find_configurations ${CMAKE_CONFIGURATION_TYPES})
else()
    _ace_debug_msg("Single configuration generator: ${CMAKE_BUILD_TYPE}")
    set(_ace_find_configurations ${CMAKE_BUILD_TYPE})
endif()

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
    set(ACE_LIBRARIES)
    _ace_debug_msg("Preset ACE_FOUND=${ACE_FOUND}")
    foreach(_ace_comp ${ACE_FIND_COMPONENTS})
        _ace_debug_msg("  checking component: ${_ace_comp}")
        string(TOUPPER "${_ace_comp}" _ace_comp_up)
        # Going to find this particular component
        _ace_find_component(${_ace_comp})
        # Check if component is mandatory
        # Did we find smth?
        if(TARGET ACE::${_ace_comp})
            _ace_debug_msg("  found component: ${_ace_comp}")
            list(APPEND ACE_LIBRARIES "ACE::${_ace_comp}")
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

    _ace_debug_msg("Final ACE_FOUND=${ACE_FOUND}")

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
# X-Chewy-Version: 2.0
# X-Chewy-Description: Find ACE library (and components) using `pkg-config` if available
# X-Chewy-AddonFile: ace_get_version.cpp
