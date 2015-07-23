# - Write and probably install a CMake finder module for package
#
# TODO More elaborate docs
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
include(CMakePackageConfigHelpers)

function(write_package_finder)
    set(options)
    set(one_value_args COMPONENT FILE_PREFIX INSTALL_DESTINATION)
    set(multi_value_args PATH_VARS)
    cmake_parse_arguments(_write_package_finder "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT _write_package_finder_FILE_PREFIX)
        set(_write_package_finder_FILE_PREFIX "${PROJECT_NAME}")
    endif()

    if(NOT _write_package_finder_COMPONENT)
        set(_write_package_finder_COMPONENT "${PROJECT_NAME}")
    endif()

    if(NOT _write_package_finder_INSTALL_DESTINATION)
        if(DEFINED CMAKE_INSTALL_CMAKE_MODULESDIR)
            set(_write_package_finder_INSTALL_DESTINATION "${CMAKE_INSTALL_CMAKE_MODULESDIR}")
        elseif(DEFINED CMAKE_INSTALL_LIBDIR)
            set(_write_package_finder_INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake")
        elseif(DEFINED CMAKE_INSTALL_DATADIR)
            set(_write_package_finder_INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/cmake")
        else()
            message(FATAL_ERROR "No `INSTALL_DESTINATION` given to `write_package_finder()`")
        endif()
    endif()

    configure_package_config_file(
        ${_write_package_finder_FILE_PREFIX}-config.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${_write_package_finder_FILE_PREFIX}-config.cmake
        INSTALL_DESTINATION ${_write_package_finder_INSTALL_DESTINATION}
        PATH_VARS
            CMAKE_INSTALL_PREFIX
            ${_write_package_finder_PATHS}
      )

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${_write_package_finder_FILE_PREFIX}-config-version.cmake
        COMPATIBILITY SameMajorVersion
      )

    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${_write_package_finder_FILE_PREFIX}-config.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/${_write_package_finder_FILE_PREFIX}-config-version.cmake
        DESTINATION ${_write_package_finder_INSTALL_DESTINATION}
        COMPONENT ${_write_package_finder_COMPONENT}
      )
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: WritePackageFinder.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Write a CMake finder module for package
