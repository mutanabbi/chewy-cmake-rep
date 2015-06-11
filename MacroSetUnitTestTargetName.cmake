#
# Macro to set a target name for unit test binary
#
# Some generators allow to have a targets w/ same name if they are
# reside in different locations in the source tree. It is really convenient
# to have a bash completion for binaries produced w/ Boost Test,
# but the problem is that completion function should "know" a name
# of the binary -- it is why having the same name is good.
#
# Usage:
#   set_unit_test_target_name(
#       OUTPUT_VARIABLE
#       DEFAULT_VALUE
#     )
#   OUTPUT_VARIABLE -- variable to set to target name in parent scope (because of macro)
#   DEFAULT_VALUE   -- a value to assign if used generator do not support policy CMP0002 in OLD state
#
# ATTENTION Do not forget to add the following snippet to the beginning of your
# root CMakeLists.txt:
#
#   if(CMAKE_GENERATOR STREQUAL "Unix Makefiles")
#         cmake_policy(SET CMP0002 OLD)
#   endif()
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

macro(set_unit_test_target_name OUTPUT_VARIABLE DEFAULT_VALUE)
    if(CMAKE_GENERATOR STREQUAL "Unix Makefiles")
        set(${OUTPUT_VARIABLE} "unit_tests")
    else()
        set(${OUTPUT_VARIABLE} ${DEFAULT_VALUE})
    endif()
endmacro()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: MacroSetUnitTestTargetName.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Function to set a target name for unit test binary
