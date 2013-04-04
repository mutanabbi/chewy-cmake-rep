# Copyright 2010 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find VMime library.
#
# Search for VMime library and set variables:
#
#  VMime_FOUND        - is library found.
#  VMime_LIBRARIES    - libs for dynamic linkage.
#  VMime_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(VMime vmime)

find_package_handle_standard_args(VMime DEFAULT_MSG VMime_LIBRARIES)

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/FindVMime.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find VMime librarary using `pkg-config`
