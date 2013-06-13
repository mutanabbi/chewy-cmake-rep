# - Find Tasn1 using `pkg-config`
# Search for Tasn1 and set the following variables:
#  TASN1_FOUND        - is package found
#  TASN1_VERSION      - found package version
#  TASN1_INCLUDE_DIRS - dir w/ header files
#  TASN1_DEFINITIONS  - other than `-I' compiler flags
#  TASN1_LIBRARIES    - libs for dynamic linkage
#

#=============================================================================
# Copyright 2010 by Alex Turbov <i.zaufi@gmail.com>
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

# Check if already in cache
# NOTE Feel free to check/change/add any other vars
if(NOT TASN1_LIBRARIES)

    if(TASN1_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()

    set(_pkg_module_name "libtasn1")
    if(TASN1_FIND_VERSION)
        if(TASN1_FIND_VERSION_EXACT)
            set(_pkg_module_name "${_pkg_module_name}=${TASN1_FIND_VERSION}")
        else()
            set(_pkg_module_name "${_pkg_module_name}>=${TASN1_FIND_VERSION}")
        endif()
    endif()

    find_package(PkgConfig ${_pkg_find_quietly})
    pkg_check_modules(TASN1 ${_pkg_module_name} ${_pkg_find_quietly})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        Tasn1
        FOUND_VAR TASN1_FOUND
        REQUIRED_VARS TASN1_LIBRARIES
        VERSION_VAR TASN1_VERSION
      )

    if(TASN1_FOUND)
        # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
        # according CMake guide (/usr/share/cmake/Modules/readme.txt)
        set(TASN1_DEFINITIONS ${TASN1_CFLAGS_OTHER})
        # Unset non-standard variable
        unset(TASN1_CFLAGS_OTHER)
    endif()
endif()

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindTasn1.cmake
# X-Chewy-Version: 1.1
# X-Chewy-Description: Find Tasn1 librarary using `pkg-config`
