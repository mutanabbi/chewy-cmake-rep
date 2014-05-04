# - Find Apache ZooKeeper C API libraries
# Search for OTL heder(s) and set the following variables:
#   ZOOKEEPERC_FOUND        - is package found
#   ZOOKEEPERC_VERSION      - found package version
#   ZOOKEEPERC_INCLUDE_DIRS - dir w/ header files
#   ZOOKEEPERC_LIBRARIES    - required libraries to link w/
#
# One may give a hint(s) to the finder via the following variabled:
#   ZOO_ROOT_DIR            - base root direcotry of the package
#   ZOO_INCLUDE_DIR         - direcotry w/ ZooKeeper C API headers
#   ZOO_LIBRARY             - full path to libzookeeper_mt.so
#
# TODO Little more tests if ZooKeeper libraries installed somewhere
# else than default (well known system-wide locations).
#

#
# Copyright (C) 2014, Alex Turbov <i.zaufi@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
#

# Check if already in cache
# NOTE Feel free to check/change/add any other vars
if(NOT ZOO_INCLUDE_DIRS)
    # Check if ZOO_ROOT_DIR is set
    if(ZOO_ROOT_DIR)
        if(NOT ZOO_INCLUDE_DIR)
            set(ZOO_INCLUDE_DIR "${ZOO_ROOT_DIR}/include")
        endif()
        if(NOT ZOO_LIBRARY)
            set(ZOO_LIBRARY "${ZOO_ROOT_DIR}/lib/libzookeeper_mt.so")
        endif()
    endif()

    # Try to find required ZooKeeper header(s)
    include(CheckIncludeFile)
    set(CMAKE_REQUIRED_INCLUDES "${ZOO_INCLUDE_DIR}")
    check_include_file("zookeeper/zookeeper.h" HAVE_ZOOKEEPER_H)

    # Try to find ZooKeeper library to link against
    include(CheckLibraryExists)
    check_library_exists(zookeeper_mt zookeeper_init "${ZOO_LIBRARY}" HAVE_LIBZOOKEEPER)

    if(HAVE_ZOOKEEPER_H AND HAVE_LIBZOOKEEPER)
        # Try to compile sample test which would (try to) output the OTL version
        try_run(
            _zoo_get_version_run_result
            _zoo_get_version_compile_result
            ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}/zookeeper_get_version
            CMAKE_FLAGS
                -DINCLUDE_DIRECTORIES:STRING=${ZOO_INCLUDE_DIR}
            COMPILE_OUTPUT_VARIABLE _zoo_get_version_compile_output
            RUN_OUTPUT_VARIABLE ZOOKEEPERC_VERSION
          )

        if(ZOO_INCLUDE_DIR)
            set(ZOOKEEPERC_INCLUDE_DIRS "${ZOO_INCLUDE_DIR}")
        endif()

        if(ZOO_LIBRARY)
            set(ZOOKEEPERC_LIBRARIES "${ZOO_LIBRARY}")
        endif()

    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        ZooKeeperC
        FOUND_VAR ZOOKEEPERC_FOUND
        REQUIRED_VARS ZOOKEEPERC_VERSION
        VERSION_VAR ZOOKEEPERC_VERSION
        FAIL_MESSAGE "ZooKeeper C API not found. You can download it from http://zookeeper.apcahe.org"
      )
endif()

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindZooKeeperC.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Apache ZooKeeper C API libraries
# X-Chewy-AddonFile: zookeeper_get_version.cc
