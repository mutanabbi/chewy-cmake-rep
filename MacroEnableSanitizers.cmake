# - Macro to expand a list of sanitizers to compiler options
# Actually particular compiler option will be tested and enabled
# if compiler supports it.
#
# Synopsis:
#   enable_sanitizers(SANITIZERS_LIST)
#
# ATTENTION Chewy intermodule dependency from UseCompilerOption
#

#=============================================================================
# Copyright 2014 by Alex Turbov <i.zaufi@gmail.com>
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

include(UseCompilerOption)

macro(enable_sanitizers)
    set(_with_sanitizers ${ARGN})
    if(_with_sanitizers)
        set(_asan_used FALSE)
        set(_tsan_used FALSE)
        foreach(_san ${_with_sanitizers})
            string(TOUPPER "${_san}" WITH_SANITIZER_UP)
            string(REPLACE "-" "_" WITH_SANITIZER_UP "${WITH_SANITIZER_UP}")
            if(_san STREQUAL thread)
                if(_asan_used)
                    message(FATAL_ERROR "Thread and address sanitizers couldn't be used both at the same time")
                endif()
                use_compiler_option(-pie OUTPUT CXX_COMPILER_HAS_PIE_OPTION)
                set(_tsan_used TRUE)
            elseif(_san STREQUAL address)
                if(_tsan_used)
                    message(FATAL_ERROR "Thread and address sanitizers couldn't be used both at the same time")
                endif()
                set(_asan_used TRUE)
            endif()
            use_compiler_option(
                -fsanitize=${_san}
                OUTPUT CXX_COMPILER_HAS_FSANITIZE_${WITH_SANITIZER_UP}_OPTION
                ALSO_PASS_TO_LINKER
              )
        endforeach()
        unset(_asan_used)
        unset(_tsan_used)
    endif()
endmacro()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: MacroEnableSanitizers.cmake
# X-Chewy-Version: 1.1
# X-Chewy-Description: Macro to expand a list of sanitizers to compiler options
# X-Chewy-AddonFile: UseCompilerOption.cmake
