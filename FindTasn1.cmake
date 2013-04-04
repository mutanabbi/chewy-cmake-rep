# Copyright 2010 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find TASN1 library.
#
# Search for TASN1 library and set variables:
#
#  TASN1_FOUND        - is library found.
#  TASN1_LIBRARIES    - libs for dynamic linkage.
#  TASN1_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(TASN1 libtasn1)

find_package_handle_standard_args(Tasn1 DEFAULT_MSG TASN1_LIBRARIES)

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/FindTasn1.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Tasn1 librarary using `pkg-config`
