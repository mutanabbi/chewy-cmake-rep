# - Find VMime package using `pkg-config`
# Search for VMime package and set the following variables:
#  VMime_FOUND        - is package found
#  VMime_VERSION      - found package version
#  VMime_INCLUDE_DIRS - dir w/ header files
#  VMime_DEFINITIONS  - other than `-I' compiler flags
#  VMime_LIBRARIES    - libs for dynamic linkage
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

if(VMime_FIND_QUIETLY)
    set(_pkg_find_quietly QUIET)
endif()

set(_pkg_module_name "vmime")
if(VMime_FIND_VERSION)
    if(VMime_FIND_VERSION_EXACT)
        set(_pkg_module_name "${_pkg_module_name}=${VMime_FIND_VERSION}")
    else()
        set(_pkg_module_name "${_pkg_module_name}>=${VMime_FIND_VERSION}")
    endif()
endif()

find_package(PkgConfig ${_pkg_find_quietly})
pkg_check_modules(VMime ${_pkg_module_name} ${_pkg_find_quietly})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    VMime
    FOUND_VAR VMime_FOUND
    REQUIRED_VARS VMime_LIBRARIES
    VERSION_VAR VMime_VERSION
  )

if(VMime_FOUND)
    # Copy other than `-I' flags to `XXX_DEFINITIONS' variable,
    # according CMake guide (/usr/share/cmake/Modules/readme.txt)
    set(VMime_DEFINITIONS ${VMime_CFLAGS_OTHER})
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindVMime.cmake
# X-Chewy-Version: 1.2
# X-Chewy-Description: Find VMime librarary using `pkg-config`
