# Copyright 2011-2013 by Alex Turbov <i.zaufi@gmail.com>
#

# prepare shell script file
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/check_headers.sh.in
    ${CMAKE_BINARY_DIR}/check_headers.sh
  )
# add `check-headers' target w/ deps
add_custom_target(check-headers /bin/sh ${CMAKE_BINARY_DIR}/check_headers.sh)
add_dependencies(check-headers ${CMAKE_CURRENT_LIST_DIR}/check_headers.sh.in)

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: DefineCheckHeadersTarget.cmake
# X-Chewy-Version: 1.1
# X-Chewy-Description: Check header files for self-sufficiency
# X-Chewy-AddonFile: check_headers.sh.in
