#
# Copyright 2011-2013 by Alex Turbov <i.zaufi@gmail.com>
#
# Find `doxygen` (and `mscgen`), render a `Doxyfile` and define 
# a target 'doxygen' to build a project documentation.
#

# check if doxygen is even installed
find_package(Doxygen)
if(DOXYGEN_FOUND STREQUAL "NO")
    message(WARNING "Doxygen not found. Please get a copy http://www.doxygen.org to produce HTML documentation")
else()
    # Try to find `mscgen` as well
    find_program(
        DOXYGEN_MSCGEN_EXECUTABLE
        NAMES mscgen
        DOC "Message Sequence Chart renderer (http://www.mcternan.me.uk/mscgen/)"
      )
    if(DOXYGEN_MSCGEN_EXECUTABLE)
        get_filename_component(DOXYGEN_MSCGEN_PATH "${MSCGEN_EXECUTABLE}" PATH CACHE)
    endif()

    # prepare doxygen configuration file
    configure_file(${CMAKE_SOURCE_DIR}/cmake/support/Doxyfile.in ${CMAKE_BINARY_DIR}/Doxyfile)

    # add doxygen as target
    add_custom_target(
        doxygen
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile
        DEPENDS ${CMAKE_BINARY_DIR}/Doxyfile
      )

    # cleanup $build/docs on "make clean"
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES docs)
    set_property(TARGET doxygen PROPERTY EchoString "Generate API documentation")
endif()

# X-Chewy-URL: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/DefineDoxyDocsTargetIfPossible.cmake
# X-Chewy-Version: 1.3
