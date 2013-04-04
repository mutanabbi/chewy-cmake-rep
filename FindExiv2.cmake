# Copyright 2012-2013 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find Exiv2 library.
#
# Search for Exiv2 library and set variables:
#
#  Exiv2_FOUND        - is library found.
#  Exiv2_LIBRARIES    - libs for dynamic linkage.
#  Exiv2_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(Exiv2 exiv2)

find_package_handle_standard_args(Exiv2 DEFAULT_MSG Exiv2_LIBRARIES)

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/FindExiv2.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Exiv2 library using `pkg-config`
