# - Find Exiv2 library package using `pkg-config`
# Search for Exiv2 library package and set the following variables:
#  EXIV2_FOUND        - is package found
#  EXIV2_VERSION      - found package version
#  EXIV2_INCLUDE_DIRS - dir w/ header files
#  EXIV2_DEFINITIONS  - other than `-I' compiler flags
#  EXIV2_LIBRARIES    - libs for dynamic linkage
#

#=============================================================================
# Copyright 2012-2013 by Alex Turbov <i.zaufi@gmail.com>
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
if(NOT EXIV2_LIBRARIES)

    if(EXIV2_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()

    set(_pkg_module_name "exiv2")
    if(EXIV2_FIND_VERSION)
        if(EXIV2_FIND_VERSION_EXACT)
            set(_pkg_module_name "${_pkg_module_name}=${EXIV2_FIND_VERSION}")
        else()
            set(_pkg_module_name "${_pkg_module_name}>=${EXIV2_FIND_VERSION}")
        endif()
    endif()

    find_package(PkgConfig ${_pkg_find_quietly})
    pkg_check_modules(EXIV2 ${_pkg_module_name} ${_pkg_find_quietly})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        Exiv2
        REQUIRED_VARS EXIV2_LIBRARIES
        VERSION_VAR EXIV2_VERSION
      )

    if(EXIV2_FOUND)
        # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
        # according CMake guide (/usr/share/cmake/Modules/readme.txt)
        set(EXIV2_DEFINITIONS ${EXIV2_CFLAGS_OTHER})
        # Unset non-standard variable
        unset(EXIV2_CFLAGS_OTHER)
    endif()
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindExiv2.cmake
# X-Chewy-Version: 1.3
# X-Chewy-Description: Find Exiv2 library using `pkg-config`
