# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#.rst:
# FindPythonPackage
# -----------------
#
# Find Python package(s)
#
# This module finds if Python package is available. Sometimes build
# process may involve Python scripts, e.g. to generate sources or execute tests.
# They could depend on third party Python packages, so it's better to ensure
# their availability before start to build anything.
#
# To search for packages one ought to specify their names as ``COMPONENTS`` to
# :command:`find_package` command:
#
# .. code-block:: cmake
#
#       find_package(
#           PythonPackage 3.5 REQUIRED
#           COMPONENTS jinja2 requests
#           OPTIONAL_COMPONENTS pytest
#       )
#
# .. note:: Requesting any particular version in call to :command:`find_package` affect
#           the Python interpreter's version only, which is used to find listed packages!
#           There is no a "native" way to require individual package's
#           versions, so this finder do not do any version match for them!
#
# This code sets the following variables:
#
# .. cmake:variable:: PYTHON_PACKAGE_<COMPONENT>_FOUND
#
#    Have the requested Python package been found
#
# .. cmake:variable:: PYTHON_PACKAGE_<COMPONENT>_VERSION
#
#   Version of the corresponding package, if available.
#   The finder module tries to get a package version doing the following steps:
#
#   1. check if package provides PEP-396 [#PEP-396]_ compatible version -- i.e.
#      ``__version__`` attribute;
#
#   2. check if package provides ``version`` attribute;
#
#   3. otherwise, set ``PYTHON_<COMPONENT>_VERSION`` to ``NOTFOUND`` value.
#
# .. [#PEP-396] PEP 396, "Module Version Numbers", Barry Warsaw
#   (https://www.python.org/dev/peps/pep-0396/)
#

include(CMakeFindDependencyMacro)
find_dependency(PythonInterp ${PACKAGE_FIND_VERSION})
if(NOT PYTHON_EXECUTABLE)
    message(WARNING "Unable to find Python interpreter")
endif()

if(NOT PythonPackage_FIND_COMPONENTS)
    message(FATAL_ERROR "No Python package to find has specified")
endif()

# Everything is gonna be alright...
set(PythonPackage_FOUND TRUE)

list(REMOVE_DUPLICATES PythonPackage_FIND_COMPONENTS)
foreach(_package IN LISTS PythonPackage_FIND_COMPONENTS)
    string(TOUPPER ${_package} _package_upper)

    if(NOT PythonPackage_FIND_QUIETLY)
        message(STATUS "Looking for Python package ${_package}")
    endif()

    execute_process(
        COMMAND
            "${PYTHON_EXECUTABLE}" "-c"
            "import ${_package} as pkg2find
if hasattr(pkg2find, '__path__'):
    print(';'.join(list(pkg2find.__path__)))
elif hasattr(pkg2find, '__file__'):
    print(pkg2find.__file__)
else:
    print('NOTFOUND')
"
        RESULT_VARIABLE _result
        OUTPUT_VARIABLE PYTHON_PACKAGE_${_package_upper}_PATH
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(_result EQUAL 0)
        set(PYTHON_PACKAGE_${_package_upper}_FOUND TRUE)

        if(NOT PythonPackage_FIND_QUIETLY)
            message(STATUS "Looking for Python package ${_package} - found")
            execute_process(
                COMMAND
                    "${PYTHON_EXECUTABLE}" "-c"
                    "import ${_package} as pkg2find
if hasattr(pkg2find, '__version__'):
    print(pkg2find.__version__)
elif hasattr(pkg2find, 'version'):
    print(pkg2find.version)
else:
    print('NOTFOUND')
"
                OUTPUT_VARIABLE PYTHON_PACKAGE_${_package_upper}_VERSION
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            if(PYTHON_PACKAGE_${_package_upper}_VERSION)
                set(_msg_version_tail " version ${PYTHON_PACKAGE_${_package_upper}_VERSION}")
            endif()

            # Show version and path if possible
            if(PYTHON_PACKAGE_${_package_upper}_PATH)
                message(STATUS "Found Python package ${_package}${_msg_version_tail}: ${PYTHON_PACKAGE_${_package_upper}_PATH}")
            elseif(_msg_version_tail)
                message(STATUS "Found Python package ${_package}${_msg_version_tail}")
            endif()

            unset(_msg_version_tail)
        endif()

    else()
        set(PYTHON_PACKAGE_${_package_upper}_FOUND NOTFOUND)
        set(PythonPackage_FOUND NOTFOUND)

        if(NOT PythonPackage_FIND_QUIETLY)
            message(STATUS "Looking for Python package ${_package} - not found")
        endif()

        if(PythonPackage_FIND_REQUIRED_${_package})
            message(FATAL_ERROR "Python package ${_package} is required but not found")
        endif()
    endif()

endforeach()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: FindPythonPackage.cmake
# X-Chewy-Version: 1.0
# X-Chewy-Description: Find Python package(s)
