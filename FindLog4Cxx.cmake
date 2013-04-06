# Copyright 2013 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find log4cxx library.
#
# Search for log4cxx library and set variables:
#
#  LOG4CXX_FOUND        - is library found.
#  LOG4CXX_LIBRARIES    - libs for dynamic linkage.
#  LOG4CXX_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(LOG4CXX liblog4cxx)
find_package_handle_standard_args(Log4Cxx DEFAULT_MSG LOG4CXX_LIBRARIES)

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindLog4Cxx.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Log4Cxx library using `pkg-config`
