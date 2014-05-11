# Copyright 2010 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find UnixODBC library.
#
# Search for UnixODBC library and set variables:
#
#  UnixODBC_FOUND        - is library found.
#  UnixODBC_LIBRARIES    - libs for dynamic linkage.
#  UnixODBC_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)

find_library(UnixODBC_LIBRARIES odbc)
find_path(UnixODBC_INCLUDE_DIRS unixodbc_conf.h)

find_package_handle_standard_args(UnixODBC DEFAULT_MSG UnixODBC_LIBRARIES UnixODBC_INCLUDE_DIRS)

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindUnixODBC.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find UnixODBC librarary
