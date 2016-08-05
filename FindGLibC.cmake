# - Find GNU libc extensions library
#
# Most popular is Run-Time extensions (`librt`)
#
# TODO Docs
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


# Check if already found
if(NOT GLIBC_LIBRARIES)
    # Set default component
    if(NOT GLibC_FIND_COMPONENTS)
        set(GLibC_FIND_COMPONENTS rt)
    endif()

    set(GLIBC_FOUND ON)
    foreach(_comp IN LISTS GLibC_FIND_COMPONENTS)
        string(TOUPPER "${_comp}" _comp_up)
        find_library(GLIBC_${_comp_up}_LIBRARY ${_comp})
        list(APPEND GLIBC_LIBRARIES "${GLIBC_${_comp_up}_LIBRARY}")
        if(GLIBC_${_comp_up}_LIBRARY)
            set(GLIBC_${_comp_up}_FOUND ON)
            if(NOT TARGET GLibC::${_comp})
                add_library(GLibC::${_comp} UNKNOWN IMPORTED)
                set_property(
                    TARGET GLibC::${_comp}
                    APPEND PROPERTY IMPORTED_LOCATION "${GLIBC_${_comp_up}_LIBRARY}"
                  )
            endif()
        else()
            set(GLIBC_FOUND OFF)
        endif()
    endforeach()

    include(GetGNULibCVersion)

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
        GLIBC
        FOUND_VAR GLIBC_FOUND
        REQUIRED_VARS GLIBC_LIBRARIES
        VERSION_VAR GLIBC_VERSION
      )
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindGLibC.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: GNU libc extensions finder
# X-Chewy-AddonFile: GetGNULibCVersion.cmake
# X-Chewy-AddonFile: glibc_get_version.c
