#.rst:
# SASS2CSS
# --------
#
# Add the function to preprocess SASS to CSS using `compass` or `sass`.
#

#=============================================================================
# Copyright 2016-2017 by Alex Turbov <i.zaufi@gmail.com>
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

get_property(_sass_name TARGET Sass::processor PROPERTY SASS_PROCESSOR_NAME)
if(_sass_name STREQUAL "sass")

    # Declare the helper function, which is capable to call `sass` executable
    function(_sass2css_process_helper INPUT_FILE OUTPUT_FILE COMPRESSED)
        if(COMPRESSED)
            set(_style_opt "--style=compressed")
        endif()

        get_filename_component(_css_dir "${OUTPUT_FILE}" DIRECTORY)

        add_custom_command(
            OUTPUT "${OUTPUT_FILE}"
            COMMAND Sass::processor
                --no-cache
                ${_style_opt}
                --sourcemap=none
                "${INPUT_FILE}"
                "${OUTPUT_FILE}"
            DEPENDS "${INPUT_FILE}"
            COMMENT "Preprocessing ${INPUT_FILE}"
            WORKING_DIRECTORY "${_css_dir}"
          )
    endfunction()

elseif(_sass_name STREQUAL "compass")

    # Declare helper function which is capable to call `compass` executable
    function(_sass2css_process_helper INPUT_FILE OUTPUT_FILE COMPRESSED)
        if(COMPRESSED)
            set(_style_opt "--output-style=compressed")
        endif()

        get_filename_component(_sass_dir "${INPUT_FILE}" DIRECTORY)
        get_filename_component(_css_dir "${OUTPUT_FILE}" DIRECTORY)

        add_custom_command(
            OUTPUT "${OUTPUT_FILE}"
            COMMAND Sass::processor
                compile
                ${_style_opt}
                --no-debug-info
                --no-sourcemap
                --environment=production
                --sass-dir="${_sass_dir}"
                # TODO Introduce some option to specify images directory?
                --images-dir="${_sass_dir}"
                --css-dir="${_css_dir}"
                "${INPUT_FILE}"
            DEPENDS "${INPUT_FILE}"
            COMMENT "Preprocessing ${INPUT_FILE}"
            WORKING_DIRECTORY "${_css_dir}"
          )
        # TODO Rename output file if `OUTPUT_FILE` filename really not the same as input
    endfunction()

else()
    function(_sass2css_process_helper INPUT_FILE OUTPUT_FILE COMPRESSED)
    endfunction()
endif()

#.rst:
#
# .. cmake:command:`sass2css_process_file`
#
# .. code-block:: cmake
#
#   sass2css_process_file(
#       INPUT_FILE "<filename>"
#       [OUTPUT_FILE "<filename>"]
#       [DEFINE_UPDATE_TARGET]
#       [DESTINATION "path"]
#     )
#
function(sass2css_process_file)
    set(_options COMPRESSED DEFINE_UPDATE_TARGET)
    set(_one_value_args INPUT_FILE OUTPUT_FILE DESTINATION)
    set(_multi_value_args )
    cmake_parse_arguments(preprocess_sass "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    # Check input file parameter
    if(NOT preprocess_sass_INPUT_FILE)
        message(FATAL_ERROR "No INPUT_FILE has provided to `preprocess_sass()`")
    elseif(NOT IS_ABSOLUTE "${preprocess_sass_INPUT_FILE}")
        # Ok, filename is given relative to current directory:
        # form an absolute path then
        get_filename_component(
            preprocess_sass_INPUT_FILE "${preprocess_sass_INPUT_FILE}"
            ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
          )
    endif()

    # Guess output filename if `OUTPUT_FILE` parameter is omitted
    if(NOT preprocess_sass_OUTPUT_FILE)
        get_filename_component(preprocess_sass_OUTPUT_FILE "${preprocess_sass_INPUT_FILE}" NAME_WE)
        string(APPEND preprocess_sass_OUTPUT_FILE ".css")
    endif()

    # Turn into an absolute path relative to binary directory
    if(NOT IS_ABSOLUTE "${preprocess_sass_OUTPUT_FILE}")
        get_filename_component(
            preprocess_sass_OUTPUT_FILE "${preprocess_sass_OUTPUT_FILE}"
            ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}"
          )
    endif()

    # Make sure destination directory exists
    get_filename_component(_css_dir "${preprocess_sass_OUTPUT_FILE}" DIRECTORY)
    if(NOT EXISTS "${_css_dir}")
        file(MAKE_DIRECTORY "${_css_dir}")
    endif()

    # Ok, guess destination directory for update target
    if(preprocess_sass_DEFINE_UPDATE_TARGET AND NOT preprocess_sass_DESTINATION)
        get_filename_component(preprocess_sass_DESTINATION "${preprocess_sass_INPUT_FILE}" DIRECTORY)
    endif()

    # Append generation rules only if any SASS preprocessor has found
    if(TARGET Sass::processor)
        _sass2css_process_helper(
            "${preprocess_sass_INPUT_FILE}"
            "${preprocess_sass_OUTPUT_FILE}"
            "${preprocess_sass_COMPRESSED}"
          )

        get_filename_component(_input_file_name_we "${preprocess_sass_OUTPUT_FILE}" NAME_WE)
        get_filename_component(_input_file_name "${preprocess_sass_OUTPUT_FILE}" NAME)

        # Make sure .css file will be processed by `make` command,
        # so later it could be `install()`ed
        add_custom_target(
            rebuild-${_input_file_name_we}-css ALL
            DEPENDS "${preprocess_sass_OUTPUT_FILE}"
          )

        if(preprocess_sass_DEFINE_UPDATE_TARGET)
            add_custom_target(
                update-${_input_file_name_we}-css
                COMMAND "${CMAKE_COMMAND}" -E copy "${preprocess_sass_OUTPUT_FILE}" "${preprocess_sass_DESTINATION}"
                DEPENDS
                    "${preprocess_sass_INPUT_FILE}"
                    "${preprocess_sass_OUTPUT_FILE}"
                BYPRODUCTS "${preprocess_sass_DEFINE_UPDATE_TARGET}/${_input_file_name}"
                COMMENT "Updating ${preprocess_sass_DESTINATION}/${_input_file_name_we}.css"
              )
        endif()
    else()
        message(STATUS "WARNING: SASS processor was not found. `sass2css_process_file()` will do nothing!")
    endif()
endfunction()

unset(_sass_name)

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: SASS2CSS.cmake
# X-Chewy-Version: 2.0
# X-Chewy-Description: Preprocess SASS to CSS
