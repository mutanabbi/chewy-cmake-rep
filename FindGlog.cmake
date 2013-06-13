# - Find Google Log library using `pkg-config`
# Search for Google Log library and set the following variables:
#  GLOG_FOUND        - is package found
#  GLOG_VERSION      - found package version
#  GLOG_INCLUDE_DIRS - dir w/ header files
#  GLOG_DEFINITIONS  - other than `-I' compiler flags
#  GLOG_LIBRARIES    - libs for dynamic linkage
#

#=============================================================================
# Copyright 2013 by Alex Turbov <i.zaufi@gmail.com>
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
if(NOT GLOG_LIBRARIES)

    if(GLOG_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()

    set(_pkg_module_name "libglog")
    if(GLOG_FIND_VERSION)
        if(GLOG_FIND_VERSION_EXACT)
            set(_pkg_module_name "${_pkg_module_name}=${GLOG_FIND_VERSION}")
        else()
            set(_pkg_module_name "${_pkg_module_name}>=${GLOG_FIND_VERSION}")
        endif()
    endif()

    find_package(PkgConfig ${_pkg_find_quietly})
    pkg_check_modules(GLOG ${_pkg_module_name} ${_pkg_find_quietly})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        Glog
        FOUND_VAR GLOG_FOUND
        REQUIRED_VARS GLOG_LIBRARIES
        VERSION_VAR GLOG_VERSION
      )

    if(GLOG_FOUND)
        # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
        # according CMake guide (/usr/share/cmake/Modules/readme.txt)
        set(GLOG_DEFINITIONS ${GLOG_CFLAGS_OTHER})
        # Unset non-standard variable
        unset(GLOG_CFLAGS_OTHER)
    endif()
endif()

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindGlog.cmake
# X-Chewy-Version: 1.2
# X-Chewy-Description: Find Google Log library using `pkg-config`
