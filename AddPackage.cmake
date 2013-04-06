# Copyright 2011-2013 by Alex Turbov <i.zaufi@gmail.com>
#
# Command to add a target to make a specified package.
#
# Example:
#
#   add_package(
#       NAME libzencxx
#       SUMMARY "C++11 reusable code collection"
#       DESCRIPTION "Header only libraries"
#       PACKAGE_VERSION 0ubuntu1
#       DEPENDS boost
#       SET_DEFAULT_CONFIG_CPACK
#     )
#
# TODO Add `cpack' programs detection
#
# TODO Add param to specify more .deb specific params like:
#   CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
#   CPACK_DEBIAN_PACKAGE_REPLACES
#

include(CMakeParseArguments)

function(add_package)
    set(options SET_DEFAULT_CONFIG_CPACK)
    set(one_value_args NAME SUMMARY DESCRIPTION PACKAGE_VERSION SECTION HOMEPAGE)
    set(multi_value_args DEPENDS REPLACES PRE_BUILD)
    cmake_parse_arguments(add_package "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    # Check mandatory parameters
    # 0) package name
    if(NOT add_package_NAME)
        message(FATAL_ERROR "Package name is not given")
    else()
        set(PACKAGE_NAME "${add_package_NAME}")
        string(TOUPPER "${add_package_NAME}" pkg_name)
        string(REPLACE "-" "_" pkg_name "${pkg_name}")
        set(${pkg_name}_PACKAGE "${add_package_NAME}" PARENT_SCOPE)
    endif()
    # 1) package description
    if(NOT add_package_SUMMARY OR NOT add_package_DESCRIPTION)
        message(FATAL_ERROR "Package description and/or summary is not provided")
    else()
        set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${add_package_SUMMARY}")
        set(CPACK_PACKAGE_DESCRIPTION "${add_package_DESCRIPTION}")
    endif()

    # Check optional parameters
    if (add_package_SET_DEFAULT_CONFIG_CPACK)
        set(config_file CPackConfig.cmake)
    else()
        set(config_file CPack-${add_package_NAME}.cmake)
    endif()
    # package version
    if(NOT add_package_PACKAGE_VERSION)
        set(CPACK_PACKAGE_VERSION "0ubuntu1")
    else()
        set(CPACK_PACKAGE_VERSION "${add_package_PACKAGE_VERSION}")
    endif()
    # package homepage
    if(add_package_HOMEPAGE)
        set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${add_package_HOMEPAGE}")
    endif()
    # dependencies list
    if(add_package_DEPENDS)
        # Form a comma separated list of dependencies from a cmake's list
        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_DEPENDS "${add_package_DEPENDS}")
    endif()
    # replaces list
    if(add_package_REPLACES)
        # Form a comma separated list of dependencies from a cmake's list
        string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_REPLACES "${add_package_REPLACES}")
    endif()

    # Generate a package specific cpack's config file to be used
    # at custom execution command...
    configure_file(
        ${CMAKE_SOURCE_DIR}/cmake/cpack/CPackConfig.cmake.in
        ${CMAKE_BINARY_DIR}/${config_file}
      )
    # Add target to create the specified package using just the generated config file
    add_custom_target(
        ${add_package_NAME}-package
        COMMAND cpack --config ${config_file}
        DEPENDS ${add_package_PRE_BUILD}
        COMMENT "Makeing package ${add_package_NAME}"
      )
endfunction()

# kate: hl cmake;
# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: AddPackage.cmake
# X-Chewy-Version: 2.5
# X-Chewy-Description: Add a target to make a .deb package
