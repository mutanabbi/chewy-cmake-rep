# Copyright 2011 by Alex Turbov <i.zaufi@gmail.com>
#
# - Try to find the libmagic library.
#
# Once done this will define
#
#  MAGIC_FOUND - system has libmagic
#  MAGIC_INCLUDE_DIR - the libmagic include directory
#  MAGIC_LIBRARIES - The libraries needed to use libmagic

find_library(MAGIC_LIBRARIES magic)
find_path(MAGIC_INCLUDE_DIR magic.h)

find_package_handle_standard_args(Magic DEFAULT_MSG MAGIC_LIBRARIES MAGIC_INCLUDE_DIR)

# TODO Check for some symbols?

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindMagic.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find MIME-type detection library
