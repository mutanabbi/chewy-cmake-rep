# - Check if a function requires linking w/ GNU libc extensions (librt, libdl, ...)
#
# TODO For some symbols special `#define`s could be needed.
#

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

include(CheckSymbolExists)
include(CheckLibraryExists)

function(check_glibc_extension_function _FUNC)
    set(_options)
    set(_one_value_args IN_LIBRARY)
    set(_multi_value_args HEADER)
    cmake_parse_arguments(_check_glibc_extension_function "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if(NOT _FUNC)
        message(FATAL_ERROR "No function name to check has been given")
    endif()

    if(NOT _check_glibc_extension_function_IN_LIBRARY)
        message(FATAL_ERROR "No library name to check has been given")
    endif()

    if(NOT TARGET GLibC::${_check_glibc_extension_function_IN_LIBRARY})
        add_library(GLibC::${_check_glibc_extension_function_IN_LIBRARY} INTERFACE IMPORTED)
    endif()

    string(TOUPPER "${_FUNC}" _func_up)
    string(TOUPPER "${_check_glibc_extension_function_IN_LIBRARY}" _lib_up)

    check_symbol_exists(${_FUNC} "${_check_glibc_extension_function_HEADER}" HAVE_${_func_up})
    if(NOT HAVE_${_func_up})
        # Try to find it in runtime extensions library
        check_library_exists(${_check_glibc_extension_function_IN_LIBRARY} ${_FUNC} "" HAVE_${_func_up}_IN_${_lib_up})
        if(HAVE_${_func_up}_IN_${_lib_up})
            find_library(
                GLIBC_${_lib_up}_LIBRARY
                ${_check_glibc_extension_function_IN_LIBRARY}
              )
            set_property(
                TARGET GLibC::${_check_glibc_extension_function_IN_LIBRARY}
                PROPERTY INTERFACE_LINK_LIBRARIES "${GLIBC_${_lib_up}_LIBRARY}"
              )
        endif()
    else()
        # Ok, it seems somehow the symbol was found.
        # Lets check if any library required for it, otherwise no library required to get this symbol,
        # so leave the `GlibC::xxx` target as is.
        if(HAVE_${_func_up}_IN_${_lib_up})
            set_property(
                TARGET GLibC::${_check_glibc_extension_function_IN_LIBRARY}
                PROPERTY INTERFACE_LINK_LIBRARIES "${GLIBC_${_lib_up}_LIBRARY}"
              )
        endif()
    endif()
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: CheckGNULibCExtensions.cmake
# X-Chewy-Version: 1.1
# X-Chewy-Description: Check if a function requires linking w/ GNU libc runtime extensions (librt)
