# - After `GNUInstallDirs.cmake` module got fixed to obey GNU/FHS standards,
# CMake internally still do not follow it... As a result, rendered `cmake_install.cmake`
# scripts from a build directory, still prepend `CMAKE_INSTALL_PREFIX` for `SYSCONFDIR`
# and `LOCALSTATEDIR`. That is a reason of RPM packages build failure, when local build
# configured to prefix other than `/usr`.
#
# Example:
#   gnu_install(
#       FILES config/jira-bot.conf
#       DESTINATION "${CMAKE_INSTALL_SYSCONFDIR}/jira-bot/"
#     )
#
# TODO More elaborate description and docs...

#=============================================================================
# Copyright 2017 by Alex Turbov <i.zaufi@gmail.com>
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

set(_GNU_INSTALL_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

# TODO Handle installs into `/opt/*` as well
function(gnu_install)
    set(_options)
    set(_one_value_args COMPONENT DESTINATION OUTPUT_SCRIPT)
    set(_multi_value_args FILES)
    cmake_parse_arguments(_gnu_install "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if(NOT _gnu_install_FILES)
        message(FATAL_ERROR "`FILES` is required in order to call `gnu_install()`")
    endif()
    if(NOT _gnu_install_DESTINATION)
        message(FATAL_ERROR "`DESTINATION` is required in order to call `gnu_install()`")
    endif()
    if(NOT _gnu_install_OUTPUT_SCRIPT)
        message(FATAL_ERROR "`OUTPUT_SCRIPT` is required in order to call `gnu_install()`")
    endif()
    if(_gnu_install_COMPONENT)
        set(_comp COMPONENT "${_gnu_install_COMPONENT}")
    endif()

    configure_file("${_GNU_INSTALL_LIST_DIR}/gnu_install.cmake.in" "${_gnu_install_OUTPUT_SCRIPT}" @ONLY)

    install(SCRIPT ${_gnu_install_OUTPUT_SCRIPT} ${_comp})

endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: GNUInstallHelpers.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Workaround to proper install files to `SYSCONFDIR` and `LOCALSTATEDIR`
# X-Chewy-AddonFile: gnu_install.cmake.in
