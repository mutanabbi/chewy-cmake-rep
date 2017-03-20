# - Functions to talk to JFrog Artifactory via REST API
#
# TODO Docs
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

find_program(CURL_EXECUTABLE curl)
mark_as_advanced(CURL_EXECUTABLE)

set(_ARTIFACTORY_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Check if user/pass has given explicitly at configure step
if(ARTIFACTORY_USER AND ARTIFACTORY_PASS)
    set(_ARTIFACTORY_DEFAULT_CREDENTIALS "-u" "${ARTIFACTORY_USER}:${ARTIFACTORY_PASS}")
elseif(ARTIFACTORY_API_KEY)
    set(_ARTIFACTORY_DEFAULT_CREDENTIALS "-H" "X-JFrog-Art-Api:${ARTIFACTORY_API_KEY}")
# Ok, lets check environment variables
elseif($ENV{ARTIFACTORY_USER} AND $ENV{ARTIFACTORY_PASS})
    set(_ARTIFACTORY_DEFAULT_CREDENTIALS "-u" "$ENV{ARTIFACTORY_USER}:$ENV{ARTIFACTORY_PASS}")
elseif($ENV{ARTIFACTORY_API_KEY})
    set(_ARTIFACTORY_DEFAULT_CREDENTIALS "-H" "X-JFrog-Art-Api:$ENV{ARTIFACTORY_API_KEY}")
# Then finally try to find credentials from the RC file in the user's HOME
elseif(EXISTS "$ENV{HOME}/.artifactoryrc.cmake")
    include("$ENV{HOME}/.artifactoryrc.cmake" RESULT_VARIABLE _artrc)
    if(_artrc)
        if(DEFINED USER AND DEFINED PASS)
            set(_ARTIFACTORY_DEFAULT_CREDENTIALS "-u" "${USER}:${PASS}")
        elseif(DEFINED API_KEY)
            set(_ARTIFACTORY_DEFAULT_CREDENTIALS "-H" "X-JFrog-Art-Api:${API_KEY}")
        endif()
    endif()
endif()

function(artifactory_verbose msg)
    if($ENV{VERBOSE})
        message("[Artifactory] ${msg}")
    endif()
endfunction()

function(artifactory_send_files)
    if(NOT CURL_EXECUTABLE)
        message(FATAL_ERROR "`curl` not found, but required for sending to Artifactory")
    endif()

    set(_options)
    set(_one_value_args TIMEOUT URL_TEMPLATE WORKING_DIRECTORY)
    set(_multi_value_args FILES PROPERTIES)
    cmake_parse_arguments(_artifactory_send_files "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if(NOT _artifactory_send_files_URL_TEMPLATE)
        message(FATAL_ERROR "`URL_TEMPLATE` parameter is required")
    elseif(NOT _artifactory_send_files_URL_TEMPLATE MATCHES "%\\(file\\)")
        message(FATAL_ERROR "`URL_TEMPLATE='${_artifactory_send_files_URL_TEMPLATE}'` do not contain `%(file)` placeholder")
    endif()

    if(NOT _artifactory_send_files_FILES)
        message(FATAL_ERROR "`FILES` parameter is required")
    endif()

    if(NOT _artifactory_send_files_WORKING_DIRECTORY)
        set(_artifactory_send_files_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    if(_artifactory_send_files_PROPERTIES)
        set(_artifactory_send_files_PROPERTIES ";${_artifactory_send_files_PROPERTIES}")
    endif()

    if(NOT _artifactory_send_files_TIMEOUT)
        set(_artifactory_send_files_TIMEOUT "20")
    endif()

    # Listen to `VERBOSE` environment variable -- it'll provided by `make`
    # if user requested verbose output...
    if("$ENV{VERBOSE}")
        set(_verbose "-v" "-s")
    endif()

    foreach(_file IN LISTS _artifactory_send_files_FILES)
        # Form the final URI
        get_filename_component(_filename "${_file}" NAME)
        string(REPLACE "%(file)" "${_filename}" _url "${_artifactory_send_files_URL_TEMPLATE}")

        file(MD5 "${_file}" _md5_sum)
        if(_md5_sum)
            list(APPEND _headers "-H" "X-Checksum-Md5: ${_md5_sum}")
        endif()
        file(SHA1 "${_file}" _sha1_sum)
        if(_sha1_sum)
            list(APPEND _headers "-H" "X-Checksum-Sha1: ${_sha1_sum}")
        endif()

        # Send it!
        execute_process(
            COMMAND "${CURL_EXECUTABLE}"
                ${_verbose}
                ${_ARTIFACTORY_DEFAULT_CREDENTIALS}
                -m ${_artifactory_send_files_TIMEOUT}
                ${_headers}
                -T "${_file}"
                "${_url}${_artifactory_send_files_PROPERTIES}"
            WORKING_DIRECTORY "${_artifactory_send_files_WORKING_DIRECTORY}"
            RESULT_VARIABLE _curl_rc
          )
        if(NOT _curl_rc EQUAL 0)
            message(FATAL_ERROR "Error while uploading file `${_file}`")
        endif()
    endforeach()

endfunction()


function(artifactory_get_latest_abi_dump OUTPUT_FILENAME)
    set(_options)
    set(_one_value_args FILENAME_GLOB PATH REPOSITORY_URL RESULT_VARIABLE TIMEOUT WORKING_DIRECTORY)
    set(_multi_value_args)
    cmake_parse_arguments(_artifactory_get_latest_abi_dump "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    # Verify mandatory parameters
    # - `OUTPUT_FILENAME` is the must
    if(NOT OUTPUT_FILENAME)
        message(FATAL_ERROR "No output filename given in call to `artifactory_get_latest_abi_dump()`")
    endif()
    # - w/o `REPOSITORY_URL` there is nothing to do
    if(NOT _artifactory_get_latest_abi_dump_REPOSITORY_URL)
        message(FATAL_ERROR "`REPOSITORY_URL` parameter is required")
    endif()
    if(NOT _artifactory_get_latest_abi_dump_FILENAME_GLOB)
        message(FATAL_ERROR "`FILENAME_GLOB` parameter is required")
    endif()

    # if `WORKING_DIRECTORY` is omitted, suppose it is `CMAKE_CURRENT_BINARY_DIR`
    if(NOT _artifactory_get_latest_abi_dump_WORKING_DIRECTORY)
        set(_artifactory_get_latest_abi_dump_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    if(NOT _artifactory_get_latest_abi_dump_TIMEOUT)
        set(_artifactory_get_latest_abi_dump_TIMEOUT "20")
    endif()

    # Listen to `VERBOSE` environment variable -- it'll provided by `make`
    # if user requested verbose output...
    if("$ENV{VERBOSE}")
        set(_verbose "-v" "-s")
    endif()

    # Produce a search URL and repository name from a base repo URL.
    # ATTENTION It is important that `REPOSITORY_URL` do not have a trailing slash!
    # TODO Strip '/' if present!
    get_filename_component(
        _artifactory_get_latest_abi_dump_REPOSITORY
        "${_artifactory_get_latest_abi_dump_REPOSITORY_URL}"
        NAME
      )
    string(REPLACE "/${_artifactory_get_latest_abi_dump_REPOSITORY}"
        ""
        _artifactory_get_latest_abi_dump_SEARCH_URL
        "${_artifactory_get_latest_abi_dump_REPOSITORY_URL}"
      )
    string(APPEND _artifactory_get_latest_abi_dump_SEARCH_URL "/api/search/aql")

    # ATTENTION It is important that `PATH` do not have a trailing slash!
    # TODO Strip '/' if present!

    # Ok, render AQL to be send
    file(READ "${_ARTIFACTORY_LIST_DIR}/artifactory_get_dumps.aql.in" _template)
    string(CONFIGURE "${_template}" _aql @ONLY)
    artifactory_verbose("Going to send AQL:\n${_aql}")

    # Search for ABI dumps at specified repository and get `version` and `name` properties
    # transforming from JSON into a CSV format. If no files found, return `NOTFOUND` which
    # is synonym of `false` for CMake.
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E echo "${_aql}"
        COMMAND "${CURL_EXECUTABLE}"
            ${_verbose}
            ${_ARTIFACTORY_DEFAULT_CREDENTIALS}
            -m "${_artifactory_get_latest_abi_dump_TIMEOUT}"
            -H "Content-Type: text/plain"
            -d "@-"
            "${_artifactory_get_latest_abi_dump_SEARCH_URL}"
        COMMAND "${JQ_EXECUTABLE}" "-r"
            "if .range.total == 0 then \"NOTFOUND\" else .results[]|[.properties[].value, .name]|join(\",\") end"
        WORKING_DIRECTORY "${_artifactory_get_latest_abi_dump_WORKING_DIRECTORY}"
        OUTPUT_VARIABLE _abi_dumps_list
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _curl_rc
      )
    # Make sure `curl` has no errors...
    if(NOT _curl_rc EQUAL 0)
        if(_artifactory_get_latest_abi_dump_RESULT_VARIABLE)
            message(WARNING "Error while querying Artifactory server")
            set(${_artifactory_get_latest_abi_dump_RESULT_VARIABLE} -400 PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "Error while querying Artifactory server")
        endif()
    endif()
    # ... and we've got some results
    if(NOT _abi_dumps_list)
        if(_artifactory_get_latest_abi_dump_RESULT_VARIABLE)
            message(WARNING "No ABI dumps found at Atrifactory storage")
            set(${_artifactory_get_latest_abi_dump_RESULT_VARIABLE} 1 PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "No ABI dumps found at Atrifactory storage")
        endif()
    endif()

    # Initialize expected results
    set(_selected_version 0.0.0)
    set(_selected_file)

    # Transform lines into a list and check what we've got
    string(REPLACE "\n" ";" _abi_dumps_list "${_abi_dumps_list}")
    foreach(_line IN LISTS _abi_dumps_list)
        if(_line MATCHES "([^,]+),(.*)")
            set(_abi_dump_version "${CMAKE_MATCH_1}")
            set(_abi_dump_file "${CMAKE_MATCH_2}")
            if(_selected_version VERSION_LESS _abi_dump_version)
                set(_selected_version "${_abi_dump_version}")
                set(_selected_file "${_abi_dump_file}")
            endif()
        else()
            if(_artifactory_get_latest_abi_dump_RESULT_VARIABLE)
                message(WARNING "Unexpected response: `${_line}`")
                set(${_artifactory_get_latest_abi_dump_RESULT_VARIABLE} -100 PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "Unexpected response: `${_line}`")
            endif()
        endif()
    endforeach()

    if(NOT _selected_file)
        # TODO Need `assert()` in CMake
        # Normally it shouldn't happened... only if the loop above is totally broken
        message(FATAL_ERROR "No ABI dump has selected")
    endif()

    # Ok, we've got a winner, lets download it
    set(_url "${_artifactory_get_latest_abi_dump_REPOSITORY_URL}")
    if(_artifactory_get_latest_abi_dump_PATH)
        string(APPEND _url "/${_artifactory_get_latest_abi_dump_PATH}")
    endif()
    string(APPEND _url "/${_selected_file}")

    execute_process(
        COMMAND "${CURL_EXECUTABLE}"
            ${_verbose}
            ${_ARTIFACTORY_DEFAULT_CREDENTIALS}
            -m "${_artifactory_get_latest_abi_dump_TIMEOUT}"
            -o "${OUTPUT_FILENAME}"
            "${_url}"
        WORKING_DIRECTORY "${_artifactory_get_latest_abi_dump_WORKING_DIRECTORY}"
        RESULT_VARIABLE _curl_rc
      )
    if(NOT _curl_rc EQUAL 0)
        if(_artifactory_get_latest_abi_dump_RESULT_VARIABLE)
            message(WARNING "Error while retrieving latest ABI dump from `${_url}`")
            set(${_artifactory_get_latest_abi_dump_RESULT_VARIABLE} -401 PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "Error while retrieving latest ABI dump from `${_url}`")
        endif()
    endif()
    set(${_artifactory_get_latest_abi_dump_RESULT_VARIABLE} 0 PARENT_SCOPE)
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: Artifactory.cmake
# X-Chewy-Version: 1.2
# X-Chewy-Description: Helper functions to talk to JFrog Artifactory server via REST API
