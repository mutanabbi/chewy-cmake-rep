# Copyright 2011-2013 by Alex Turbov <i.zaufi@gmail.com>

# prepare shell script file
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/support/check_headers.sh.in
    ${CMAKE_BINARY_DIR}/cmake/support/check_headers.sh
  )
# add `check-headers' target w/ deps
add_custom_target(check-headers /bin/sh ${CMAKE_BINARY_DIR}/cmake/support/check_headers.sh)
add_dependencies(check-headers ${CMAKE_BINARY_DIR}/cmake/support/check_headers.sh)

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/DefineCheckHeadersTarget.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Check header files for self-sufficiency
