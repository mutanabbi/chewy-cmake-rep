#
# Copyright 2011-2013 by Alex Turbov <i.zaufi@gmail.com>
#
# Find `doxygen` (and `mscgen`), render a `Doxyfile` and define
# a target 'doxygen' to build a project documentation.
#

option(NO_DOXY_DOCS "Do not install Doxygen'ed documentation")

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

    # set some variables before geenrate a config file
    if(NOT PROJECT_API_DOC_DIR)
        set(PROJECT_API_DOC_DIR ${PROJECT_BINARY_DIR}/doc)
    endif()
    if(NOT DOXYGEN_EXCLUDE_PATTERNS)
        set(DOXYGEN_EXCLUDE_PATTERNS "*/.git/* */.svn/* */.hg/* */tests/* *_tester.cc")
    endif()

    # prepare doxygen configuration file
    configure_file(${CMAKE_CURRENT_LIST_DIR}/Doxyfile.in ${CMAKE_BINARY_DIR}/Doxyfile)

    # add doxygen as target
    add_custom_target(
        doxygen
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile
        DEPENDS ${CMAKE_BINARY_DIR}/Doxyfile
        COMMENT "Generate API documentation"
      )

    # cleanup $build/docs on "make clean"
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES docs)

    find_program(
        XDG_OPEN_EXECUTABLE
        NAMES xdg-open
        DOC "opens a file or URL in the user's preferred application"
      )
    if(XDG_OPEN_EXECUTABLE)
        message(STATUS "Enable 'show-api-documentation' target via ${XDG_OPEN_EXECUTABLE}")
        add_custom_target(
            show-api-documentation
            COMMAND ${XDG_OPEN_EXECUTABLE} ${PROJECT_API_DOC_DIR}/html/index.html
            DEPENDS ${CMAKE_BINARY_DIR}/Doxyfile
            COMMENT "Open API documentation"
          )
        add_dependencies(show-api-documentation doxygen)
    endif()

    if(NOT NO_DOXY_DOCS)
        # make sure documentation will be produced before (possible) install
        configure_file(
            ${CMAKE_CURRENT_LIST_DIR}/DoxygenInstall.cmake.in
            ${CMAKE_BINARY_DIR}/DoxygenInstall.cmake
            @ONLY
          )
        install(SCRIPT ${CMAKE_BINARY_DIR}/DoxygenInstall.cmake)
    endif()
endif()

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: DefineDoxyDocsTargetIfPossible.cmake
# X-Chewy-Version: 1.5
# X-Chewy-Description: Define `make doxygen` target to build API documentation using `doxygen`
# X-Chewy-AddonFile: Doxyfile.in
# X-Chewy-AddonFile: DoxygenInstall.cmake.in
