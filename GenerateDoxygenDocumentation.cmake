# - Add a target to generate doxygen documentation
#
# Usage:
#   generate_doxygen_documentation(
#       target-name
#       [CONFIG file.in]
#       [OUTPUT_CONFIG file]
#       [COMMENT text]
#     )
# If `CONFIG` option is ommited, `Doxyfile.in` from cmake modules dir will be used.
# If `OUTPUT_CONFIG` option is ommited, `Doxyfile` in current binary dir will be used.
#
# To configure desired doxygen options one may set them before
# call `generate_doxygen_documentation()`. Every doxygen variabl
# (found in ordinal Doxyfile) must be prefixed w/ `DOXYGEN_` to be
# defined form CMake script.
#
# Tools like `dot`, `mscgen` and `dia` also will be detected automatically and
# corresponding options in `Doxyfile` will be defined.
#

#=============================================================================
# Copyright 2014-2017 by Alex Turbov <i.zaufi@gmail.com>
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

set(_GDD_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# check if doxygen is even installed
find_package(Doxygen)

# Finding other tools have any sense only if `doxygen` has found
if(DOXYGEN_FOUND)
    # Try to find `mscgen` as well
    find_program(
        DOXYGEN_MSCGEN_EXECUTABLE
        NAMES mscgen
        DOC "Message Sequence Chart renderer (http://www.mcternan.me.uk/mscgen/)"
      )
    mark_as_advanced(DOXYGEN_MSCGEN_EXECUTABLE)
    if(NOT DOXYGEN_MSCGEN_EXECUTABLE)
        message(
            STATUS
                "WARNING: Message Sequence Chart renderer not found. "
                "Please get a copy from http://www.mcternan.me.uk/mscgen/"
          )
    endif()
    # Try to find `dia` as well
    find_program(
        DOXYGEN_DIA_EXECUTABLE
        NAMES dia
        DOC "Diagram/flowchart creation program (https://wiki.gnome.org/Apps/Dia)"
      )
    mark_as_advanced(DOXYGEN_DIA_EXECUTABLE)
    if(NOT DOXYGEN_DIA_EXECUTABLE)
        message(
            STATUS
                "WARNING: Dia not found. "
                "Please get a copy from https://wiki.gnome.org/Apps/Dia."
          )
    endif()
else()
    message(
        STATUS
            "WARNING: Doxygen not found. "
            "Please get a copy from http://www.doxygen.org to produce API documentation"
      )
endif()

function(_list_to_quoted_strings LIST_VARIABLE)
    if(DEFINED ${LIST_VARIABLE})
        foreach(_in IN LISTS ${LIST_VARIABLE})
            string(APPEND _inputs " \"${_in}\"")
        endforeach()
        set(${LIST_VARIABLE} "${_inputs}" PARENT_SCOPE)
        unset(_inputs)
    endif()
endfunction()

function(generate_doxygen_documentation target)
    set(_options)
    set(_one_value_args COMMENT CONFIG OUTPUT_CONFIG)
    set(_multi_value_args SOURCES)
    cmake_parse_arguments(_gdd "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if(NOT _gdd_CONFIG)
        set(_gdd_CONFIG "${_GDD_BASE_DIR}/Doxyfile.in")
    endif()
    if(NOT _gdd_OUTPUT_CONFIG)
        get_filename_component(_cfg_ext "${_gdd_CONFIG}" EXT)
        if(_cfg_ext MATCHES "\\.in$")
            get_filename_component(_cfg_name "${_gdd_CONFIG}" NAME)
            string(REGEX REPLACE "\\.in$" "" _cfg_name "${_cfg_name}")
        else()
            get_filename_component(_cfg_name "${_gdd_CONFIG}" NAME)
        endif()
        set(_gdd_OUTPUT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/${_cfg_name}")
    endif()
    if(NOT _gdd_COMMENT)
        set(_gdd_COMMENT "Generate API documentation")
    endif()

    # Set some variables before generate a config file
    set(DOXYGEN_STRIP_FROM_PATH "\"${PROJECT_SOURCE_DIR}\" \"${PROJECT_BINARY_DIR}\"")
    set(DOXYGEN_HAVE_DOT ${DOXYGEN_DOT_FOUND})
    if(DOXYGEN_DOT_EXECUTABLE)
        get_filename_component(DOXYGEN_DOT_PATH "${DOXYGEN_DOT_EXECUTABLE}" PATH CACHE)
        set(DOT_MULTI_TARGETS YES)
        set(DOT_CLEANUP YES)
    endif()
    if(DOXYGEN_MSCGEN_EXECUTABLE)
        get_filename_component(DOXYGEN_MSCGEN_PATH "${DOXYGEN_MSCGEN_EXECUTABLE}" PATH CACHE)
        mark_as_advanced(DOXYGEN_MSCGEN_PATH)
    endif()
    if(DOXYGEN_DIA_EXECUTABLE)
        get_filename_component(DOXYGEN_DIA_PATH "${DOXYGEN_DIA_EXECUTABLE}" PATH CACHE)
        mark_as_advanced(DOXYGEN_DIA_PATH)
    endif()

    # Set some sane defaults, but only if they are not defined yet
    if(NOT DEFINED DOXYGEN_PROJECT_NAME)
        set(DOXYGEN_PROJECT_NAME ${PROJECT_NAME})
    endif()
    if(NOT DEFINED DOXYGEN_PROJECT_NUMBER)
        set(DOXYGEN_PROJECT_NUMBER ${PROJECT_VERSION})
    endif()
    if(NOT DEFINED DOXYGEN_PROJECT_BRIEF)
        set(DOXYGEN_PROJECT_BRIEF "\"${PROJECT_BRIEF}\"")
    endif()
    if(NOT DEFINED DOXYGEN_RECURSIVE)
        set(DOXYGEN_RECURSIVE YES)
    endif()
    if(NOT DEFINED DOXYGEN_INPUT)
        set(DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}")
    endif()
    if(NOT DEFINED DOXYGEN_OUTPUT_DIRECTORY)
        set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/doc")
    endif()
    if(NOT DEFINED DOXYGEN_GENERATE_LATEX)
        set(DOXYGEN_GENERATE_LATEX NO)
    endif()
    if(NOT DEFINED DOXYGEN_WARN_FORMAT)
        if("${CMAKE_BUILD_TOOL}" MATCHES "(msdev|devenv)")
            set(DOXYGEN_WARN_FORMAT "\"$file($line) : $text \"")
        endif()
    endif()
    # Handle appendable options
    set(
        DOXYGEN_EXCLUDE_PATTERNS
        "${DOXYGEN_EXCLUDE_PATTERNS} */.git/* */.svn/* */.hg/* *_tester.cc */CMakeFiles/* */cmake/* */_CPack_Packages/* DartConfiguration.tcl CMakeLists.txt CMakeCache.txt"
      )

    # Transform lists into space separated strings
    # TODO Review doxygen options and add more list variables
    foreach(_item DOXYGEN_INPUT DOXYGEN_EXCLUDE)
        _list_to_quoted_strings(${_item})
    endforeach()

    # Get other defaults from generated file
    include("${_GDD_BASE_DIR}/DoxygenDefaults.cmake")

    # Prepare doxygen configuration file
    configure_file("${_gdd_CONFIG}" "${_gdd_OUTPUT_CONFIG}")

    if(_gdd_SOURCES)
        list(INSERT _gdd_SOURCES 0 "SOURCES")
    endif()

    # Add a new target
    add_custom_target(
        ${target}
        COMMAND "${DOXYGEN_EXECUTABLE}" "${_gdd_OUTPUT_CONFIG}"
        DEPENDS "${_gdd_CONFIG}" "${_gdd_OUTPUT_CONFIG}"
        COMMENT "${_gdd_COMMENT}"
        ${_gdd_SOURCES}
      )

    # Cleanup $build/docs on "make clean"
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${DOXYGEN_OUTPUT_DIRECTORY})
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: GenerateDoxygenDocumentation.cmake
# X-Chewy-Version: 2.4
# X-Chewy-Description: Add a target to generate doxygen documentation
# X-Chewy-AddonFile: Doxyfile.in
# X-Chewy-AddonFile: DoxygenDefaults.cmake
