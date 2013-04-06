# Copyright 2012, Alex Turbov <I.zaufi@gmail.com>
#
# - Try to find the Poco libraries
#
# Once done this will define:
#
#  POCO_FOUND - system has Poco
#  POCO_INCLUDE_DIR - the Poco include directory
#  POCO_LIBRARIES - libraries list

find_path(POCO_INCLUDE_DIR Poco/Foundation.h)

if(NOT POCO_INCLUDE_DIR MATCHES NOTFOUND)
  try_run(
      POCO_TEST_RUN_RESULT POCO_TEST_COMP_RESULT
      ${CMAKE_BINARY_DIR}
      ${CMAKE_SOURCE_DIR}/cmake/modules/poco_version_test.cpp
      RUN_OUTPUT_VARIABLE POCO_VERSION
    )

  # Ok, going to check components
  foreach(COMPONENT ${Poco_FIND_COMPONENTS})
    string(TOUPPER ${COMPONENT} UPPERCOMPONENT)

    find_library(POCO_${UPPERCOMPONENT}_LIBRARY Poco${COMPONENT})

    if(NOT POCO_${UPPERCOMPONENT}_LIBRARY MATCHES NOTFOUND)
      set(POCO_LIBRARIES "${POCO_LIBRARIES} ${POCO_${UPPERCOMPONENT}_LIBRARY}")
    else()
      set(POCO_LIBRARIES NOTFOUND)
      break()
    endif()
  endforeach()
endif()

find_package_handle_standard_args(
    Poco
    REQUIRED_VARS POCO_LIBRARIES POCO_INCLUDE_DIR
    VERSION_VAR POCO_VERSION
  )

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindPoco.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Poco libraries
