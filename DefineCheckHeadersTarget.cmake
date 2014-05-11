# - Define target to check header files for self-sufficiency
# The target will be named `check-headers'.
#

#=============================================================================
# Copyright 2011-2013 by Alex Turbov <i.zaufi@gmail.com>
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

# prepare shell script file
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/check_headers.sh.in
    ${CMAKE_BINARY_DIR}/check_headers.sh
  )
# add `check-headers' target w/ deps
add_custom_target(check-headers /bin/sh ${CMAKE_BINARY_DIR}/check_headers.sh)
add_dependencies(check-headers ${CMAKE_CURRENT_LIST_DIR}/check_headers.sh.in)

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: DefineCheckHeadersTarget.cmake
# X-Chewy-Version: 1.3
# X-Chewy-Description: Check header files for self-sufficiency
# X-Chewy-AddonFile: check_headers.sh.in
# X-Chewy-AddonFile: output_helpers.sh
