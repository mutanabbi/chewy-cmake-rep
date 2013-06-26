# - Find liburiparser package using `pkg-config`
#
# `uriparser` is a strictly RFC 3986 compliant URI parsing and handling library written in C.
#
# Search for liburiparser package and set the following variables:
#  URIPARSER_FOUND        - is package found
#  URIPARSER_VERSION      - found package version
#  URIPARSER_INCLUDE_DIRS - dir w/ header files
#  URIPARSER_DEFINITIONS  - other than `-I' compiler flags
#  URIPARSER_LIBRARIES    - libs for dynamic linkage
#
# Project homepage: http://uriparser.sourceforge.net/
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
if(NOT URIPARSER_LIBRARIES)

    if(URIPARSER_FIND_QUIETLY)
        set(_pkg_find_quietly QUIET)
    endif()

    set(_pkg_module_name "liburiparser")
    if(URIPARSER_FIND_VERSION)
        if(URIPARSER_FIND_VERSION_EXACT)
            set(_pkg_module_name "${_pkg_module_name}=${URIPARSER_FIND_VERSION}")
        else()
            set(_pkg_module_name "${_pkg_module_name}>=${URIPARSER_FIND_VERSION}")
        endif()
    endif()

    find_package(PkgConfig ${_pkg_find_quietly})
    pkg_check_modules(URIPARSER ${_pkg_module_name} ${_pkg_find_quietly})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        LibURIParser
        REQUIRED_VARS URIPARSER_LIBRARIES
        VERSION_VAR URIPARSER_VERSION
      )

    if(URIPARSER_FOUND)
        # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
        # according CMake guide (/usr/share/cmake/Modules/readme.txt)
        set(URIPARSER_DEFINITIONS ${URIPARSER_CFLAGS_OTHER})
        # Unset non-standard variable
        unset(URIPARSER_CFLAGS_OTHER)
    endif()
endif()


# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindLibURIParser.cmake
# X-Chewy-Version: 1.3
# X-Chewy-Description: Find uriparser library using `pkg-config`
