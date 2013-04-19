# Copyright 2013 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find liburiparser
#
# `uriparser` is a strictly RFC 3986 compliant URI parsing and handling library written in C.
#
# Project homepage: http://uriparser.sourceforge.net/
#
# Search for library using `pkg-config` and set variables:
#
#  URIPARSER_FOUND        - is library found.
#  URIPARSER_LIBRARIES    - libs for dynamic linkage.
#  URIPARSER_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)
include(FindPkgConfig)

pkg_check_modules(URIPARSER liburiparser)

find_package_handle_standard_args(LibURIParser DEFAULT_MSG URIPARSER_LIBRARIES)

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindLibURIParser.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find uriparser library using `pkg-config`
