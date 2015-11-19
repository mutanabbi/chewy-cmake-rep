# - Check for python module availability
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
include(FindPackageHandleStandardArgs)

# Check if `autogen` and `awk` both are installed
find_program(PYTHON_EXECUTABLE autogen)

function(check_python_module)
    set(_options REQUIRED QUIET)
    set(_one_value_args PYTHON_VERSION)
    set(_multi_value_args MODULE)
    cmake_parse_arguments(_check_python_module "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if(NOT PYTHON_EXECUTABLE)
        find_package(PythonInterp ${_check_python_module_PYTHON_VERSION} REQUIRED)
    endif()

    # Failure if no python has found
    if(NOT PYTHON_EXECUTABLE)
        message(FATAL_ERROR "Python executable required for check_python_module(), but hasn't found")
    endif()

    foreach(module ${_check_python_module_MODULE})
        if(NOT _check_python_module_QUIET)
            message(STATUS "Looking for Python module ${module}")
        endif()
        string(TOUPPER ${module} module_upper)
        if(NOT PYTHON_${module_upper}_MODULE)
            execute_process(
                COMMAND "${PYTHON_EXECUTABLE}" "-c" "import re, ${module} as module; print(re.compile('/__init__.py.*').sub('',module.__file__))"
                RESULT_VARIABLE _result
                OUTPUT_VARIABLE PYTHON_${module_upper}_MODULE
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE
              )
            if(_result EQUAL 0)
                if(NOT _check_python_module_QUIET)
                    message(STATUS "Looking for Python module ${module} - found")
                endif()
            else()
                set(PYTHON_${module_upper}_MODULE NOTFOUND)
                if(NOT _check_python_module_QUIET)
                    message(STATUS "Looking for Python module ${module} - not found")
                    if(_check_python_module_REQUIRED)
                        message(FATAL_ERROR "Module ${module} is required but not found")
                    endif()
                endif()
            endif()
            find_package_handle_standard_args(PYTHON_${module_upper}_MODULE DEFAULT_MSG PYTHON_${module_upper}_MODULE)
        endif()
    endforeach()
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: CheckPythonModule.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Check for python module availability
