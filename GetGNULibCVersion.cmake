# - Get glibc version
# Set GLIBC_VERSION variable to detected version
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

try_run(
    _GLIBC_VERSION_RUN_RESULT
    _GLIBC_VERSION_COMPILE_RESULT
    ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}/glibc_get_version.c
    RUN_OUTPUT_VARIABLE GLIBC_VERSION
  )

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: GetGNULibCVersion.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Helper to get GNU libc version
# X-Chewy-AddonFile: glibc_get_version.c
