# - Macro to redefine some install paths to have versioned component,
# so project may coexists w/ other versions of self in a same prefix.
#

#=============================================================================
# Copyright 2015 by Alex Turbov <i.zaufi@gmail.com>
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

include(CMakeParseArguments)

# Define install destination dirs
if(CMAKE_VERSION VERSION_LESS 3.4)
    include("${CMAKE_CURRENT_LIST_DIR}/GNUInstallDirs.cmake")
else()
    include(GNUInstallDirs.cmake)
endif()

macro(define_versioned_install_paths)
    set(options )
    set(one_value_args PROJECT_NAME VERSIONED_PART VERSION)
    set(multi_value_args PATHS)
    cmake_parse_arguments(_define_versioned_install_paths "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT _define_versioned_install_paths_VERSIONED_PART)
        if(NOT _define_versioned_install_paths_PROJECT_NAME)
            set(_define_versioned_install_paths_PROJECT_NAME "${PROJECT_NAME}")
        endif()
        if(NOT _define_versioned_install_paths_VERSION)
            set(
                _define_versioned_install_paths_VERSION
                "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
              )
        endif()
        set(
            _define_versioned_install_paths_VERSIONED_PART
            "${_define_versioned_install_paths_PROJECT_NAME}-${_define_versioned_install_paths_VERSION}"
          )
    endif()

    if(NOT _define_versioned_install_paths_PATHS)
        set(
            _define_versioned_install_paths_PATHS
            BINDIR
            SBINDIR
            LIBEXECDIR
            SYSCONFDIR
            SHAREDSTATEDIR
            LOCALSTATEDIR
            LIBDIR
            INCLUDEDIR
            DATADIR
            DOCDIR
            CMAKE_MODULESDIR
          )
    endif()

    foreach(_dir ${_define_versioned_install_paths_PATHS})
        # Handle special cases:
        #  - DOCDIR already contains a PROJECT_NAME, so need to rebuild this path starting from DATAROOTDIR
        if(_dir STREQUAL "DOCDIR")
            set(CMAKE_INSTALL_${_dir} "${CMAKE_INSTALL_DATAROOTDIR}/doc/${_define_versioned_install_paths_VERSIONED_PART}")
            set(CMAKE_INSTALL_FULL_${_dir} "${CMAKE_INSTALL_FULL_DATAROOTDIR}/doc/${_define_versioned_install_paths_VERSIONED_PART}")
        else()
            set(CMAKE_INSTALL_${_dir} "${CMAKE_INSTALL_${_dir}}/${_define_versioned_install_paths_VERSIONED_PART}")
            set(CMAKE_INSTALL_FULL_${_dir} "${CMAKE_INSTALL_FULL_${_dir}}/${_define_versioned_install_paths_VERSIONED_PART}")
        endif()
    endforeach()

endmacro()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: MacroDefineVersionedInstallDirs.cmake
# X-Chewy-Version: 1.2
# X-Chewy-Description: Macro to redefine some install paths to have versioned component
# X-Chewy-AddonFile: GNUInstallDirs.cmake
