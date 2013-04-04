# Copyright 2012 by Alex Turbov <i.zaufi@gmail.com>
#
# Function (macro actually :) to get a distribution codename according LSB spec
#

set(DEFAULT_DISTRIB_CODENAME "precise" CACHE STRING "Target distribution codename according LSB")

if(NOT DISTRIB_CODENAME)
  if(EXISTS /etc/lsb-release)
    file(STRINGS /etc/lsb-release distrib_codename_line REGEX "DISTRIB_CODENAME=")
    string(REGEX REPLACE "DISTRIB_CODENAME=\"?(.*)\"?" "\\1" DISTRIB_CODENAME "${distrib_codename_line}")
  else()
    set(DISTRIB_CODENAME "${DEFAULT_DISTRIB_CODENAME}" CACHE INTERNAL "Target distribution codename")
  endif()
  message(STATUS "Target distribution codename: ${DISTRIB_CODENAME}")
endif()

#kate: hl cmake;
# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/GetDistribInfo.cmake
# X-Chewy-Version: 1.2
