#.rst:
# FindSASSProcessor
# -----------------
#
# Find a SASS processor. There are few alternative (nowadays) possible:
#
# - ``sass`` which is Ruby based processor (http://sass-lang.com/)
# - ``compass`` which is also Ruby and part of the "Compass Stylesheet Authoring Framework" (http://compass-style.org/)
#
# One can control preference one implementation over another by setting :cmake:variable:`FIND_SASS_PROCESSOR_PREFER_COMPASS_OVER_SASS`.
#

#=============================================================================
# Copyright 2016 by Alex Turbov <i.zaufi@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of this repository, substitute the full
#  License text for the above reference.)

# TODO Not needed for CMake >= 3.5
include(CMakeParseArguments)

# Look for `compass` first if preferred over `sass`
if(FIND_SASS_PROCESSOR_PREFER_COMPASS_OVER_SASS)
    set(_sass_processor_names compass sass)
else()
    set(_sass_processor_names sass compass)
endif()

find_program(SASS_PROCESSOR_EXECUTABLE NAMES ${_sass_processor_names})
mark_as_advanced(SASS_PROCESSOR_EXECUTABLE)

if(SASS_PROCESSOR_EXECUTABLE)
    get_filename_component(_sass_bin_name "${SASS_PROCESSOR_EXECUTABLE}" NAME)
    if(_sass_bin_name STREQUAL "sass" OR _sass_bin_name STREQUAL "compass")
        add_executable(Sass::processor IMPORTED)
        set_property(
            TARGET Sass::processor
            PROPERTY IMPORTED_LOCATION "${SASS_PROCESSOR_EXECUTABLE}"
          )
        set_property(
            TARGET Sass::processor
            PROPERTY SASS_PROCESSOR_NAME "${_sass_bin_name}"
          )
    else()
        message(AUTHOR_WARNING "Don't know this executable `${SASS_PROCESSOR_EXECUTABLE}`")
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    SASSProcessor
    REQUIRED_VARS SASS_PROCESSOR_EXECUTABLE
  )

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindSASSProcessor.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Search for SASS preprocessor (`sass` or `compass`)
