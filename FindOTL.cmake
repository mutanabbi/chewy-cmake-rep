# - Find OTL
# Search for OTL heder(s) and set the following variables:
#  OTL_FOUND        - is package found
#  OTL_VERSION      - found package version
#  OTL_INCLUDE_DIRS - dir w/ header files
#  OTL_DEFINITIONS  - other than `-I' compiler flags
#  OTL_LIBRARIES    - libs for dynamic linkage
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

# Check if already in cache
# NOTE Feel free to check/change/add any other vars
if(NOT OTL_INCLUDE_DIRS)

    # Try to compile sample test which would (try to) output the OTL version
    try_run(
        _otl_get_version_run_result
        _otl_get_version_compile_result
        ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}/otl_get_version.cc
        CMAKE_FLAGS
            -DINCLUDE_DIRECTORIES:STRING=${OTL_INCLUDE_DIR}
        COMPILE_OUTPUT_VARIABLE _otl_get_version_compile_output
        RUN_OUTPUT_VARIABLE OTL_VERSION
      )

    if(OTL_INCLUDE_DIR)
        set(OTL_INCLUDE_DIRS "${OTL_INCLUDE_DIR}")
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        OTL
        FOUND_VAR OTL_FOUND
        REQUIRED_VARS OTL_VERSION
        VERSION_VAR OTL_VERSION
        FAIL_MESSAGE "OTL header not found! You may download the library from http://otl.sourceforge.net"
      )
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindOTL.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find OTL header
# X-Chewy-AddonFile: otl_get_version.cc
