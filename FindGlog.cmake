# Copyright 2013 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find Google log library
#
# Search for library using `pkg-config` and set variables:
#
#  GLOG_FOUND        - is library found.
#  GLOG_LIBRARIES    - libs for dynamic linkage.
#  GLOG_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(GLOG libglog)

find_package_handle_standard_args(Glog DEFAULT_MSG GLOG_LIBRARIES)

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/FindGlog.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Google Log library using `pkg-config`

