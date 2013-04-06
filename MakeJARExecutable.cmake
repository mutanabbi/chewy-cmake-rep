# Copyright 2010 by Alex Turbov <i.zaufi@gmail.com>
#
# Function to make a JAR executable
#
# Just inject entry point into manifest file.
# Nowadays cmake can build a JAR files but there is no way to
# specify MANIFEST.MF file, so it's not possible to produce an
# 'executable' JAR...
#
# NOTE Waiting for an implementation of the feature request here: http://www.cmake.org/Bug/view.php?id=6960
#
# Usage:
#   add_library(SomeJavaApplication ${JAVA_SOURCES})
#   make_jar_executable(SomeJavaApplication com.vendor.EntryPointClass)
#

function(make_jar_executable VAR_TARGET VAR_ENTRY)
  # NOTE LOCATION property is deprecated actually... What else to use
  # instead?? LIBRARY_OUTPUT_NAME is not defined... Any ideas?
  get_target_property(JAR_NAME ${VAR_TARGET} LOCATION)
  add_custom_command(
      TARGET ${VAR_TARGET}
      POST_BUILD COMMAND ${CMAKE_Java_ARCHIVE} ufe ${JAR_NAME} ${VAR_ENTRY}
      COMMENT "Setting ${JAR_NAME} entry point to ${VAR_ENTRY}"
    )
  unset(JAR_NAME)
endfunction(make_jar_executable)

# X-Chewy-RepoBase: https://raw.github.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-URL: FindVMime.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Function to set an entry point in the JAR file, so it become 'executable'
