# - Add command to preprocess SASS to CSS using `compass` or `sass`
# TODO More elaborate description

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

# Look for `sass` first
find_program(SASS_EXECUTABLE sass)
if(SASS_EXECUTABLE)
    message(STATUS "Found sass: ${SASS_EXECUTABLE}")

    function(_preprocess_sass_helper INPUT_FILE OUTPUT_FILE COMPRESSED)
        if(COMPRESSED)
            set(_style_opt "--style=compressed")
        endif()
        add_custom_command(
            OUTPUT "${OUTPUT_FILE}"
            COMMAND "${SASS_EXECUTABLE}"
                --no-cache
                ${_style_opt}
                --sourcemap=none
                "${INPUT_FILE}"
                "${OUTPUT_FILE}"
            COMMENT "Preprocessing ${INPUT_FILE}"
            WORKING_DIRECTORY "${_css_dir}"
          )
    endfunction()

else()
    # Ok, try to find `compass` then...
    find_program(COMPASS_EXECUTABLE compass)
    if(COMPASS_EXECUTABLE)
        message(STATUS "Found compass: ${COMPASS_EXECUTABLE}")
        function(_preprocess_sass_helper INPUT_FILE OUTPUT_FILE COMPRESSED)
            if(COMPRESSED)
                set(_style_opt "--output-style=compressed")
            endif()

            get_filename_component(_sass_dir "${INPUT_FILE}" DIRECTORY)
            get_filename_component(_css_dir "${OUTPUT_FILE}" DIRECTORY)

            add_custom_command(
                OUTPUT "${OUTPUT_FILE}"
                COMMAND "${COMPASS_EXECUTABLE}"
                    compile
                    ${_style_opt}
                    --no-debug-info
                    --environment=production
                    --sass-dir="${_sass_dir}"
                    --css-dir="${_css_dir}"
                    "${INPUT_FILE}"
                COMMENT "Preprocessing ${INPUT_FILE}"
                WORKING_DIRECTORY "${_css_dir}"
              )
            # TODO Rename ourput file if `OUTPUT_FILE` filename really not the same as input
        endfunction()
    else()
        message(STATUS "SASS preprocessor: NOTFOUND")
    endif()
endif()

function(preprocess_sass)
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
    if(COMPASS_EXECUTABLE OR SASS_EXECUTABLE)
        _preprocess_sass_helper(
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
    endif()
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: SASS2CSS.cmake
# X-Chewy-Version: 1.2
# X-Chewy-Description: Preprocess SASS to CSS
