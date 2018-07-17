#[=======================================================================[.rst:

TeamCity
--------

Talk to TeamCity via service messages_.

.. _messages: https://confluence.jetbrains.com/display/TCD10/Build+Script+Interaction+with+TeamCity

Variables
^^^^^^^^^

.. variable:: TEAMCITY_IS_ACTIVE BOOL

 ``TRUE`` if running under TeamCity, ``FALSE`` otherwise.


Functions
^^^^^^^^^

.. ##teamcity[blockOpened name='<blockName>' description='<this is the description of blockName>']
.. command:: teamcity_block_start

 Start the ``blockOpened`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_block_start(
         <name>
         [description-line-1 ... [description-line-n]]
       )

 Blocks are used to group several messages in the build log.  The
 ``blockOpened`` system message allows the name attribute, you can also
 add a description to the to the ``blockOpened`` message.

 So, evry additional parameter after ``name`` considered
 as a description line.


.. ##teamcity[blockClosed name='<blockName>']
.. command:: teamcity_block_end

 Send the ``blockClosed`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_block_end()

 Automatically closes the last opened block.


.. ##teamcity[message text='<message text>' errorDetails='<error details>' status='<status value>']
.. command:: teamcity_message

 Send the ``message`` type message, which is just a message ;-)

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_message(<status> <text>)

 - ``status`` is one of the following: ``NORMAL``,
   ``WARNING``, ``FAILURE``, ``ERROR``. If status is ``ERROR``, any
   additional parameters (after ``text``) are considered
   as *error details*.  This way usually used to pass a stack trace;
 - ``text`` message text string.


.. ##teamcity[compilationStarted compiler='<compiler name>']
.. command:: teamcity_compile_start

 Send the ``compilationStarted`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_compile_start(<compiler>)

 - ``compiler`` is an arbitrary name of the compiler
   performing compilation.

 .. note::

    Any message with status ``ERROR`` reported between
    :command:`teamcity_compile_start` and
    :command:`teamcity_compile_end` will be treated as a
    compilation error.


.. ##teamcity[compilationFinished compiler='<compiler name>']
.. command:: teamcity_compile_end

 Send the ``compilationFinished`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_compile_end()


.. ##teamcity[progressStart '<message>']
.. command:: teamcity_progress_start

 Send the ``progressStart`` message.  Progress message blocks could be nested.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_progress_start(<text>)

 You can use special progress messages to mark long-running parts in a
 build script.  These messages will be shown on the projects dashboard
 for the corresponding build and on the Build Results page.

 See also :command:`teamcity_progress`.


.. ##teamcity[progressFinish '<message>']
.. command:: teamcity_progress_end

 Send the ``progressFinish`` message, closing latest opened progress block.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_progress_end()


.. ##teamcity[progressMessage '<message>']
.. command:: teamcity_progress

 Send the ``progressMessage`` message.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_progress(<message>)

 This progress message will be shown until another progress message occurs
 or until the next target starts (in case of Ant builds).


.. ##teamcity[testSuiteStarted name='suiteName']
.. command:: teamcity_test_suite_start

 Send the ``testSuiteStarted`` message.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_suite_start(<name>)

 Test suites are used to group tests.  TeamCity displays tests grouped by
 suites on Tests tab of the Build Results page and in other places.


.. ##teamcity[testSuiteFinished name='suiteName']
.. command:: teamcity_test_suite_end

 Send the ``testSuiteFinished`` message, closing latest opened test suite.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_suite_end()


.. ##teamcity[testStarted name='testName' captureStandardOutput='<true/false>']
.. command:: teamcity_test_start

 Send the ``testStarted`` message.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_start(<name> [CAPTURE_OUTPUT])

 Optional named argument ``CAPTURE_OUTPUT`` makes all the
 standard output (and standard error) messages received between
 :command:`teamcity_test_start` and :command:`teamcity_test_end`
 will be considered test output.  The default value is false and assumes
 usage of service messages to report the test output.

 .. note::

     In the later versions, starting another test finishes the currently
     started test in the same "flow".


.. ##teamcity[testFinished name='testName' duration='<test_duration_in_milliseconds>']
.. command:: teamcity_test_end

 Send the ``testFinished`` message, closing latest opened test block.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_end([DURATION <milliseconds>])

 Optionally one can sets the test duration in milliseconds (should be an
 integer) to be reported in TeamCity UI.  If omitted, the test duration
 will be calculated from the messages timestamps.  If the timestamps are
 missing, from the actual time the messages were received on the server.


.. ##teamcity[testFailed name='MyTest.test1' message='failure message' details='message and stack trace']
.. ##teamcity[testFailed type='comparisonFailure' name='MyTest.test2' message='failure message'
..            details='message and stack trace' expected='expected value' actual='actual value']
.. command:: teamcity_test_failed


 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_failed(
         <message>
         [DETAILS <details>]
         [ACTUAL <actual>]
         [EXPECTED <expected>]
       )

 Indicates that the current test failed.  Only one ``testFailed`` message
 can appear for a given test name.

 - ``message`` contains the textual representation
   of the error;
 - ``details`` contains detailed information on the test
   failure, typically a message and an exception stacktrace;
 - ``actual`` and ``expected`` can only be
   used together to report comparison failure.
   The values will be used when opening the test in the IDE.


.. ##teamcity[testIgnored name='testName' message='ignore comment']
.. command:: teamcity_test_ignored

 Send the ``testIgnored`` message.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_ignored(<name> <message>)

 Indicates that the test ``name`` is present but was not
 run (was ignored) by the testing framework.  As an exception, the
 ``testIgnored`` message can be reported without the matching
 ``testStarted`` and ``testFinished`` messages.


.. ##teamcity[testStdOut name='className.testName' out='text']
.. command:: teamcity_test_output

 Send the ``testStdOut`` message.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_output(<text>)


.. ##teamcity[testStdErr name='className.testName' out='error text']
.. command:: teamcity_test_error_output

 Send the ``testStdErr`` message.

 .. code-block:: cmake
    :caption: **Synopsis**

     teamcity_test_error_output(<text>)


.. ##teamcity[publishArtifacts '<path>']
.. command:: teamcity_publish_artefacts

 Send the ``publishArtifacts`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_publish_artefacts(<path>)

 The ``path`` has to adhere to the same rules as the
 Build Artifact specification of the Build Configuration settings.
 The files matching the ``path`` will be uploaded and
 visible as the artifacts of the running build.

 The message should be printed after all the files are ready and no file
 is locked for reading.


.. ##teamcity[buildProblem description='<description>' identity='<identity>']
.. command:: teamcity_build_problem

 Send the ``buildProblem`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_build_problem(<text> [identity])

 - ``text`` a human-readable plain text describing the build
   problem.  By default, the description appears in the build status text
   and in the list of build's problems.  The text is limited to 4000 symbols,
   and will be truncated if the limit is exceeded.
 - ``identity`` - an optional unique problem id.
   Different problems must have different identity, same problems - same
   identity, which should not change throughout builds if the same problem
   occurs, e.g. the same compilation error.  It should be a valid Java id
   up to 60 characters.  If omitted, the identity is calculated based
   on the description text.


.. ##teamcity[buildStatus status='<status value>' text='{build.status.text} and some aftertext']
.. command:: teamcity_build_status

 Send the ``buildStatus`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_build_status(
         [SUCCESS]
         <text>
       )

 TeamCity allows changing the build status text from the build script.
 Unlike progress messages, this change persists even after a build has finished.
 You can also change the build status of a failing build to success.

 Prior to TeamCity 7.1, this service message could be used for changing the
 build status to failed.  In the later TeamCity versions, the ``buildProblem``
 service message is to be used for that.

 Text could contain the ``{build.status.text}`` substitution pattern
 which represents the status, calculated by TeamCity automatically using
 passed test count, compilation messages and so on

 The status set will be presented while the build is running and will
 also affect the final build results.


.. ##teamcity[buildNumber '<new build number>']
.. command:: teamcity_set_build_number

 Send the ``buildNumber`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_set_build_number(<build_number>)

 In the new ``build_number`` value, you can use the
 ``{build.number}`` substitution to use the current build number
 automatically generated by TeamCity.  For example ``1.2.3_{build.number}-ent``.


.. ##teamcity[setParameter name='ddd' value='fff']
.. command:: teamcity_set_param

 Send the ``setParameter`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_set_param(<name> <value>)

 You can dynamically update build parameters of the build right from a
 build step (the parameters need to be defined in the Parameters section of
 the build configuration).  The changed build parameters will be available
 in the build steps following the modifying one.  They will also be available
 as build parameters and can be used in the dependent builds via
 ``%dep.*%`` parameter references.

 When specifying a build parameter's name, mind the prefix:

 - ``system`` for system properties;
 - ``env`` for environment variables;
 - no prefix for configuration parameter.


.. ##teamcity[buildStatisticValue key='<valueTypeKey>' value='<value>']
.. command:: teamcity_build_stats

 Send the ``buildStatisticValue`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_build_stats(<key> <value>)

 where

 - The key should not be equal to any of predefined keys.
 - The value should be a positive/negative integer of up to 13 digits;
   float values with up to 6 decimal places are also supported.


.. ##teamcity[enableServiceMessages]
.. command:: teamcity_enable

 Send the ``enableServiceMessages`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_enable()

 Enable serivce messages processing.


.. ##teamcity[disableServiceMessages]
.. command:: teamcity_disable

 Send the ``disableServiceMessages`` message.

 .. code-block:: cmake
     :caption: **Synopsis:**

     teamcity_disable()

 Disable service messages processing.

#]=======================================================================]

# Author: Alex Turbov <i.zaufi@gmail.com>

include(CMakeParseArguments)

if("$ENV{TEAMCITY_VERSION}" STREQUAL "")
    set(TEAMCITY_IS_ACTIVE FALSE)
else()
    set(TEAMCITY_IS_ACTIVE TRUE)
endif()

macro(_teamcity_escape_string VAR)
    string(REPLACE "|"   "||" ${VAR} "${${VAR}}")
    string(REPLACE "\n" "|n" ${VAR} "${${VAR}}")
    string(REPLACE "'"   "|'" ${VAR} "${${VAR}}")
    string(REPLACE "["   "|[" ${VAR} "${${VAR}}")
    string(REPLACE "]"   "|]" ${VAR} "${${VAR}}")
endmacro()

function(_teamcity_bare_message NAME)
    if(TEAMCITY_IS_ACTIVE)
        # Setup message start
        set(_message "##teamcity[${NAME}")

        # Append preformatted key-value pairs
        foreach(_p ${ARGN})
            string(APPEND _message " ${_p}")
        endforeach()

        # Show message w/ closing ']'
        message("${_message}]")
    endif()
endfunction()

function(_teamcity_message NAME)
    if(TEAMCITY_IS_ACTIVE)
        # Setup message start
        string(TIMESTAMP _timestamp "%Y-%m-%dT%H:%M:%S.000" UTC)
        set(_message "##teamcity[${NAME} flowId='$ENV{TEAMCITY_PROCESS_FLOW_ID}' timestamp='${_timestamp}'")

        # Append preformatted key-value pairs
        foreach(_p ${ARGN})
            string(APPEND _message " ${_p}")
        endforeach()

        # Show message w/ closing ']'
        message("${_message}]")
    endif()
endfunction()

function(_teamcity_push_prop_stack NAME VALUE)
    set_property(GLOBAL APPEND PROPERTY TEAMCITY_${NAME} ${VALUE})
endfunction()

function(_teamcity_pop_prop_stack NAME VAR)
    get_property(_list_exists GLOBAL PROPERTY TEAMCITY_${NAME} SET)
    if(_list_exists)
        get_property(_list GLOBAL PROPERTY TEAMCITY_${NAME})
    else()
        message(FATAL_ERROR "Misbalanced block start/end calls")
    endif()
    list(GET _list 0 _id)
    list(REMOVE_AT _list 0)

    set_property(GLOBAL PROPERTY TEAMCITY_${NAME} ${_list})
    set(${VAR} "${_id}" PARENT_SCOPE)
endfunction()

macro(_teamcity_top_prop_stack NAME VAR)
    get_property(_list_exists GLOBAL PROPERTY TEAMCITY_${NAME} SET)
    if(_list_exists)
        get_property(_list GLOBAL PROPERTY TEAMCITY_${NAME})
    else()
        message(FATAL_ERROR "Misbalanced block start/end calls")
    endif()
    list(GET _list 0 ${VAR})
endmacro()

function(_teamcity_generic_bare_block_start MSGTYPE NAME ID)
    _teamcity_bare_message("${MSGTYPE}" ${ID} ${ARGN})
    _teamcity_push_prop_stack(${NAME} ${ID})
endfunction()

function(_teamcity_generic_bare_block_end MSGTYPE NAME)
    _teamcity_pop_prop_stack(${NAME} _id)
    _teamcity_bare_message("${MSGTYPE}" ${_id} ${ARGN})
endfunction()

function(_teamcity_generic_block_start MSGTYPE NAME ID)
    _teamcity_message("${MSGTYPE}" ${ID} ${ARGN})
    _teamcity_push_prop_stack(${NAME} ${ID})
endfunction()

function(_teamcity_generic_block_end MSGTYPE NAME)
    _teamcity_pop_prop_stack(${NAME} _id)
    _teamcity_message("${MSGTYPE}" ${_id})
endfunction()


function(teamcity_block_start NAME)
    _teamcity_escape_string(NAME)
    if(ARGN)
        foreach(_item IN LISTS ARGN)
            string(APPEND _description "${_glue}${_item}")
            set(_glue "\n")
        endforeach()
        _teamcity_escape_string(_description)
        _teamcity_generic_block_start("blockOpened" "BLOCK" "name='${NAME}'" "description='${_description}'")
    else()
        _teamcity_generic_block_start("blockOpened" "BLOCK" "name='${NAME}'")
    endif()
endfunction()


function(teamcity_block_end)
    _teamcity_generic_block_end("blockClosed" "BLOCK")
endfunction()


list(APPEND _TEAMCITY_MESSAGE_STATUS_LIST NORMAL WARNING FAILURE ERROR)
function(teamcity_message STATUS TEXT)
    # Check status
    if(NOT STATUS IN_LIST _TEAMCITY_MESSAGE_STATUS_LIST)
        message(FATAL_ERROR "`teamcity_message` called with invalid status")
    endif()

    _teamcity_escape_string(TEXT)
    _teamcity_escape_string(STATUS)
    if(STATUS STREQUAL "ERROR" AND ARGN)
        foreach(_item IN LISTS ARGN)
            string(APPEND _details "${_glue}${_item}")
            set(_glue "\n")
        endforeach()

        _teamcity_escape_string(_details)
        _teamcity_message("message" "text='${TEXT}'" "status='${STATUS}'" "errorDetails='${_details}'")
    else()
        _teamcity_message("message" "text='${TEXT}'" "status='${STATUS}'")
    endif()

endfunction()


function(teamcity_compile_start COMPILER)
    _teamcity_escape_string(COMPILER)
    _teamcity_generic_block_start("compilationStarted" "COMPILE" "compiler='${COMPILER}'")
endfunction()


function(teamcity_compile_end)
    _teamcity_generic_block_end("compilationFinished" "COMPILE")
endfunction()


function(teamcity_progress_start TEXT)
    _teamcity_escape_string(TEXT)
    _teamcity_generic_bare_block_start("progressStart" "PROGRESS" "'${TEXT}'")
endfunction()


function(teamcity_progress_end)
    _teamcity_generic_bare_block_end("progressFinish" "PROGRESS")
endfunction()


function(teamcity_progress MESSAGE)
    _teamcity_escape_string(MESSAGE)
    _teamcity_bare_message("progressMessage" "'${MESSAGE}'")
endfunction()


function(teamcity_test_suite_start NAME)
    _teamcity_escape_string(NAME)
    _teamcity_generic_bare_block_start("testSuiteStarted" "TEST_SUITE" "name='${NAME}'")
endfunction()


function(teamcity_test_suite_end)
    _teamcity_generic_bare_block_end("testSuiteFinished" "TEST_SUITE")
endfunction()


function(teamcity_test_start NAME)
    _teamcity_escape_string(NAME)
    if(ARGV1 STREQUAL "CAPTURE_OUTPUT")
        set(cap "true")
    else()
        set(cap "false")
    endif()
    _teamcity_generic_bare_block_start("testStarted" "TEST" "name='${NAME}'" "captureStandardOutput='${cap}'")
endfunction()


function(teamcity_test_end)
    set(one_value_args DURATION)
    cmake_parse_arguments(PARSE_ARGV 0 teamcity_test_end "" "${one_value_args}" "")

    if(teamcity_test_end_DURATION)
        _teamcity_escape_string(teamcity_test_end_DURATION)
        _teamcity_generic_bare_block_end("testFinished" "TEST" "duration='${teamcity_test_end_DURATION}'")
    else()
        _teamcity_generic_bare_block_end("testFinished" "TEST")
    endif()
endfunction()


function(teamcity_test_failed MESSAGE)
    set(one_value_args DETAILS EXPECTED ACTUAL)
    cmake_parse_arguments(PARSE_ARGV 0 teamcity_test_failed "" "${one_value_args}" "")

    set(_aux_args)
    if(NOT teamcity_test_failed_DETAILS STREQUAL "")
        _teamcity_escape_string(teamcity_test_failed_DETAILS)
        list(APPEND _aux_args "details='${teamcity_test_failed_DETAILS}'")
    endif()
    if(NOT (teamcity_test_failed_EXPECTED STREQUAL "" OR teamcity_test_failed_ACTUAL STREQUAL ""))
        list(APPEND _aux_args "type='comparisonFailure'")
        _teamcity_escape_string(teamcity_test_failed_EXPECTED)
        _teamcity_escape_string(teamcity_test_failed_ACTUAL)
        list(APPEND _aux_args "expected='${teamcity_test_failed_EXPECTED}'")
        list(APPEND _aux_args "actual='${teamcity_test_failed_ACTUAL}'")
    elseif(NOT (teamcity_test_failed_EXPECTED STREQUAL "" AND teamcity_test_failed_ACTUAL STREQUAL ""))
        message(SEND_ERROR "Invalid parameters in call to `teamcity_test_failed()`: both `ACTUAL` and `EXPECTED` must be given or omitted.")
    endif()

    _teamcity_top_prop_stack("TEST" _name)
    _teamcity_escape_string(MESSAGE)
    _teamcity_bare_message("testFailed" "${_name}" "message='${MESSAGE}'" ${_aux_args})
endfunction()


function(teamcity_test_ignored NAME MESSAGE)
    _teamcity_escape_string(NAME)
    _teamcity_escape_string(MESSAGE)
    _teamcity_bare_message("testIgnored" "name=${NAME}" "message='${MESSAGE}'")
endfunction()

function(teamcity_test_output TEXT)
    _teamcity_escape_string(TEXT)
    _teamcity_top_prop_stack("TEST" _name)
    _teamcity_bare_message("testStdOut" "${_name}" "out='${TEXT}'")
endfunction()


function(teamcity_test_error_output TEXT)
    _teamcity_escape_string(TEXT)
    _teamcity_top_prop_stack("TEST" _name)
    _teamcity_bare_message("testStdErr" "${_name}" "out='${TEXT}'")
endfunction()


function(teamcity_publish_artefacts PATH)
    _teamcity_escape_string(PATH)
    _teamcity_bare_message("publishArtifacts" "'${PATH}'")
endfunction()


function(teamcity_build_problem TEXT)
    _teamcity_escape_string(TEXT)
    if(ARGV1)
        _teamcity_escape_string(ARGV1)
        _teamcity_bare_message("buildProblem" "description='${TEXT}'" "identity='${ARGV1}'")
    else()
        _teamcity_bare_message("buildProblem" "description='${TEXT}'")
    endif()
endfunction()


function(teamcity_build_status TEXT)
    if(TEXT STREQUAL "SUCCESS")
        _teamcity_escape_string(ARGV1)
        _teamcity_bare_message("buildStatus" "status='SUCCESS'" "text='${ARGV1}'")
    else()
        _teamcity_escape_string(TEXT)
        _teamcity_bare_message("buildStatus" "text='${TEXT}'")
    endif()
endfunction()


function(teamcity_set_build_number NEW_NUMBER)
    _teamcity_escape_string(NEW_NUMBER)
    _teamcity_bare_message("buildNumber" "'${NEW_NUMBER}'")
endfunction()


function(teamcity_set_param NAME VALUE)
    _teamcity_escape_string(NAME)
    _teamcity_escape_string(VALUE)
    _teamcity_bare_message("setParameter" "name='${NAME}'" "value='${VALUE}'")
endfunction()


function(teamcity_build_stats KEY VALUE)
    _teamcity_escape_string(KEY)
    _teamcity_escape_string(VALUE)
    _teamcity_bare_message("buildStatisticValue" "key='${KEY}'" "value='${VALUE}'")
endfunction()


function(teamcity_enable)
    _teamcity_bare_message("enableServiceMessages")
endfunction()


function(teamcity_disable)
    _teamcity_bare_message("disableServiceMessages")
endfunction()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: TeamCity.cmake
# X-Chewy-Version: 2.0.0
# X-Chewy-Description: Interact w/ TeamCity via service messages
