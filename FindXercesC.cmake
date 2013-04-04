# Copyright 2011 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find XERCESC library.
#
# Search for XERCESC library and set variables:
#
#  XERCESC_FOUND        - is library found.
#  XERCESC_LIBRARIES    - libs for dynamic linkage.
#  XERCESC_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(XERCESC xerces-c)

find_package_handle_standard_args(XercesC DEFAULT_MSG XERCESC_LIBRARIES)

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/FindXercesC.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Xerces-C librarary using `pkg-config`
