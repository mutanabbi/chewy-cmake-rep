# Copyright 2010 by Alex Turbov <i.zaufi@gmail.com>
#
# - Find OpenLDAP library.
#
# Search for OpenLDAP library and set variables:
#
#  OpenLDAP_FOUND        - is library found.
#  OpenLDAP_LIBRARIES    - libs for dynamic linkage.
#  OpenLDAP_INCLUDE_DIRS - dir w/ header files.
#

include(FindPackageHandleStandardArgs)

if (NOT OpenLDAP_LIBRARIES)
  find_library(OpenLDAP_LDAP ldap)
  find_library(OpenLDAP_LBER lber)
  if (OpenLDAP_LDAP AND OpenLDAP_LBER)
    set(OpenLDAP_LIBRARIES ${OpenLDAP_LDAP} ${OpenLDAP_LBER})
  endif ()
endif ()

find_path(OpenLDAP_INCLUDE_DIRS ldap.h)

find_package_handle_standard_args(OpenLDAP DEFAULT_MSG OpenLDAP_LIBRARIES OpenLDAP_INCLUDE_DIRS)

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindOpenLDAP.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find OpenLDAP libraries
