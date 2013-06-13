# - Find log4cxx library using `pkg-config`
# Search for log4cxx library and set the following variables:
#  LOG4CXX_FOUND        - is package found
#  LOG4CXX_VERSION      - found package version
#  LOG4CXX_INCLUDE_DIRS - dir w/ header files
#  LOG4CXX_DEFINITIONS  - other than `-I' compiler flags
#  LOG4CXX_LIBRARIES    - libs for dynamic linkage
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
if(NOT LOG4CXX_LIBRARIES)

    if(LOG4CXX_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()

    set(_pkg_module_name "liblog4cxx")
    if(LOG4CXX_FIND_VERSION)
        if(LOG4CXX_FIND_VERSION_EXACT)
            set(_pkg_module_name "${_pkg_module_name}=${LOG4CXX_FIND_VERSION}")
        else()
            set(_pkg_module_name "${_pkg_module_name}>=${LOG4CXX_FIND_VERSION}")
        endif()
    endif()

    find_package(PkgConfig ${_pkg_find_quietly})
    pkg_check_modules(LOG4CXX ${_pkg_module_name} ${_pkg_find_quietly})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        Log4Cxx
        FOUND_VAR LOG4CXX_FOUND
        REQUIRED_VARS LOG4CXX_LIBRARIES
        VERSION_VAR LOG4CXX_VERSION
      )

    if(LOG4CXX_FOUND)
        # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
        # according CMake guide (/usr/share/cmake/Modules/readme.txt)
        set(LOG4CXX_DEFINITIONS ${LOG4CXX_CFLAGS_OTHER})
        # Unset non-standard variable
        unset(LOG4CXX_CFLAGS_OTHER)
    endif()
endif()

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindLog4Cxx.cmake
# X-Chewy-Version: 1.2
# X-Chewy-Description: Find Log4Cxx library using `pkg-config`
