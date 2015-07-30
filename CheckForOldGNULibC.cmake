# - Check if GNU libc < 2.17, so librt needs for RT extensions
# Set GLIBC_VERSION variable to detected version and GLIBC_EXTRA_LIBRARIES
# to GNU libc RT extensions library name.
#

#=============================================================================
# Copyright 2015 by Alex Turbov <i.zaufi@gmail.com>
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

include(GetGNULibCVersion)

if(GLIBC_VERSION VERSION_LESS 2.17)
    set(GLIBC_EXTRA_LIBRARIES rt CACHE STRING "GNU libc library with RT extensions")
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: CheckForOldGNULibC.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Check if GNU libc < 2.17, so librt needs for RT extensions
