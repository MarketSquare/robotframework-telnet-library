*** Settings ***
Documentation     This resource file contains, or imports, all general variables and keywords used by the running side of Robot Framework acceptance tests.
Library           OperatingSystem
Library           Process
Library           Collections
Library           String
Library           TestCheckerLibrary
Library           TestHelper
Library           XML
Library           read_interpreter.py
Variables         atest_variables.py

*** Variables ***
${OUTDIR}         %{TEMPDIR}/output
${OUTFILE}        ${OUTDIR}${/}output.xml
${SET SYSLOG}     True
${SYSLOG FILE}    ${OUTDIR}${/}syslog.txt
${SYSLOG LEVEL}   INFO
${STDOUT FILE}    ${OUTDIR}${/}stdout.txt
${STDERR FILE}    ${OUTDIR}${/}stderr.txt
${OUTFILE COPY}   %{TEMPDIR}/output-copy.xml
${SUITE}          Set by TestCheckerLibrary.Process Output
${ERRORS}         -- ;; --
${USAGE_TIP}      \n\nTry --help for usage information.
${TESTNAME}       ${EMPTY}    # Used when not running test
${COMMON DEFAULTS}
...               --ConsoleColors OFF
...               --output ${OUTFILE}
...               --report NONE
...               --log NONE
${RUNNER DEFAULTS}
...               ${COMMON DEFAULTS}
...               --ConsoleMarkers OFF
...               --PYTHONPATH "${CURDIR}${/}..${/}testresources${/}testlibs"
...               --PYTHONPATH "${CURDIR}${/}..${/}testresources${/}listeners"

*** Keywords ***
Run Tests
    [Arguments]    ${options}=    ${sources}=    ${output}=${OUTFILE}
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.runner}   ${options}    ${sources}    ${RUNNER DEFAULTS}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    Process Output    ${output}
    [Return]    ${result}

Run Tests Without Processing Output
    [Arguments]    ${options}=    ${sources}=
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.runner}   ${options}    ${sources}    ${RUNNER DEFAULTS}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    [Return]    ${result}

Run Tests Without Defaults
    [Arguments]    ${options}=    ${sources}=
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.runner}   ${options}    ${sources}    defaults=${EMPTY}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    [Return]    ${result}

Run Rebot
    [Arguments]    ${options}=    ${sources}=    ${output}=${OUTFILE}
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.rebot}   ${options}    ${sources}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    Process Output    ${output}
    [Return]    ${result}

Run Rebot Without Processing Output
    [Arguments]    ${options}=    ${sources}=
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.rebot}   ${options}    ${sources}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    [Return]    ${result}

Run Rebot Without Defaults
    [Arguments]    ${options}=    ${sources}=
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.rebot}   ${options}    ${sources}    defaults=${EMPTY}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    [Return]    ${result}

Execute
    [Arguments]    ${executor}    ${options}    ${sources}    ${defaults}=${COMMON DEFAULTS}
    Set Execution Environment
    @{arguments} =    Get Execution Arguments    ${options}    ${sources}    ${defaults}
    ${result} =    Run Process    @{executor}    @{arguments}
    ...    stdout=${STDOUTFILE}    stderr=${STDERRFILE}    timeout=5min    on_timeout=terminate
    [Return]    ${result}

Get Execution Arguments
    [Arguments]    ${options}    ${sources}    ${defaults}
    @{options} =    Command line to list    --outputdir ${OUTDIR} ${defaults} ${options}
    @{sources} =    Command line to list    ${sources}
    @{sources} =    Join Paths    ${DATADIR}    @{sources}
    [Return]    @{options}    @{sources}

Set Execution Environment
    Remove Directory    ${OUTDIR}    recursive
    Create Directory    ${OUTDIR}
    Return From Keyword If    not ${SET SYSLOG}
    Set Environment Variable    ROBOT_SYSLOG_FILE    ${SYSLOG FILE}
    Set Environment Variable    ROBOT_SYSLOG_LEVEL    ${SYSLOG LEVEL}

Copy Previous Outfile
    Copy File    ${OUTFILE}    ${OUTFILE COPY}

Check Test Case
    [Arguments]    ${name}=${TESTNAME}    ${status}=${NONE}    ${message}=${NONE}
    ${test} =    Get Test From Suite    ${SUITE}    ${name}
    Check Test Status    ${test}    ${status}    ${message}
    [Return]    ${test}

Check Test Suite
    [Arguments]    ${name}    ${message}    ${status}=${None}
    ${suite} =    Get Test Suite    ${name}
    Run Keyword If    $status is not None    Should Be Equal    ${suite.status}    ${status}
    Should Be Equal    ${suite.full_message}    ${message}
    [Return]    ${suite}

Get Test Case
    [Arguments]    ${name}
    ${test} =    Get Test From Suite    ${SUITE}    ${name}
    [Return]    ${test}

Get Test Suite
    [Arguments]    ${name}
    ${suite} =    Get Suite From Suite    ${SUITE}    ${name}
    [Return]    ${suite}

Check Test Doc
    [Arguments]    ${test_name}    @{expected_doc}
    ${test} =    Check Test Case    ${test_name}
    ${expected} =    Catenate    @{expected_doc}
    Should Be Equal    ${test.doc}    ${expected}
    [Return]    ${test}

Check Test Tags
    [Arguments]    ${test_name}    @{expected_tags}
    ${test} =    Check Test Case    ${test_name}
    Should Contain Tags    ${test}    @{expected_tags}
    [Return]    ${test}

Check KW Arguments
    [Arguments]    ${kw}    @{expected args}
    Lists Should Be Equal    ${kw.args}    ${expected args}

Keyword data should be
    [Arguments]    ${kw}    ${name}    ${assign}=    ${args}=
    Should be equal    ${kw.name}    ${name}
    ${kwassign}=    Catenate    SEPARATOR=,${SPACE}    @{kw.assign}
    Should be equal    ${kwassign}    ${assign}
    ${kwargs}=    Catenate    SEPARATOR=,${SPACE}    @{kw.args}
    Should match    ${kwargs}    ${args}

Check Log Message
    [Arguments]    ${item}    ${msg}    ${level}=INFO    ${html}=${False}    ${pattern}=
    ${html} =    Set Variable If    ${html} or '${level}' == 'HTML'    ${True}    ${False}
    ${level} =    Set Variable If    '${level}' == 'HTML'    INFO    ${level}
    ${checker} =    Set Variable If    '${pattern}'    Should Match    Should Be Equal
    Run Keyword    ${checker}    ${item.message.rstrip()}    ${msg.rstrip()}    Wrong log message
    Should Be Equal    ${item.level}    ${level}    Wrong log level
    Should Be Equal    ${item.html}    ${html}    Wrong HTML status

Get Output File
    [Arguments]    ${path}
    [Documentation]    Output encoding avare helper
    ${encoding} =    Evaluate    __import__('robot').utils.encoding.OUTPUT_ENCODING
    ${encoding} =    Set Variable If    r'${path}' in [r'${STDERR FILE}',r'${STDOUT FILE}']    ${encoding}    UTF-8
    ${file} =    Log File    ${path}    ${encoding}
    [Return]    ${file}

Check File Contains
    [Arguments]    ${path}    @{expected}
    ${exp} =    Catenate    @{expected}
    ${file} =    Get Output File    ${path}
    Should Contain    ${file}    ${exp}

Check File Does Not Contain
    [Arguments]    ${path}    @{expected}
    ${exp} =    Catenate    @{expected}
    ${file} =    Get Output File    ${path}
    Should Not Contain    ${file}    ${exp}

Check File Matches Regexp
    [Arguments]    ${path}    @{expected}
    ${exp} =    Catenate    @{expected}
    ${file} =    Get Output File    ${path}
    Should Match Regexp    ${file.strip()}    ^${exp}$

Check File Contains Regexp
    [Arguments]    ${path}    @{expected}
    ${exp} =    Catenate    @{expected}
    ${file} =    Get Output File    ${path}
    Should Match Regexp    ${file.strip()}    ${exp}

File Should Be Equal To
    [Arguments]    ${path}    @{expected}
    ${content} =    Get Output File    ${path}
    ${exp} =    Catenate    @{expected}
    Should Be Equal    ${content}    ${exp}

File Should Match
    [Arguments]    ${path}    @{expected}
    ${content} =    Get Output File    ${path}
    ${exp} =    Catenate    @{expected}
    Should Match    ${content}    ${exp}

File Should Contain Match
    [Arguments]    ${path}    @{expected}
    ${content} =    Get Output File    ${path}
    ${exp} =    Catenate    @{expected}
    Should Match    ${content}    *${exp}*

Stderr Should Be Equal To
    [Arguments]    @{expected}
    File Should Be Equal To    ${STDERR FILE}    @{expected}

Stderr Should Match
    [Arguments]    @{expected}
    File Should Match    ${STDERR FILE}    @{expected}

Stderr Should Be Empty
    ${stderr} =    Get Stderr
    Should Be Empty    ${stderr}    Errors in test execution:\n${stderr}

Check Stderr Contains
    [Arguments]    @{expected}
    Check File Contains    ${STDERR_FILE}    @{expected}

Check Stderr Does Not Contain
    [Arguments]    @{expected}
    Check File Does Not Contain    ${STDERR_FILE}    @{expected}

Check Stderr Matches Regexp
    [Arguments]    @{expected}
    Check File Matches Regexp    ${STDERR_FILE}    @{expected}

Check Stderr Contains Regexp
    [Arguments]    @{expected}
    Check File Contains Regexp    ${STDERR_FILE}    @{expected}

Check Stdout Contains
    [Arguments]    @{expected}
    Check File Contains    ${STDOUT_FILE}    @{expected}

Check Stdout Does Not Contain
    [Arguments]    @{expected}
    Check File Does Not Contain    ${STDOUT_FILE}    @{expected}

Check Stdout Matches Regexp
    [Arguments]    @{expected}
    Check File Matches Regexp    ${STDOUT_FILE}    @{expected}

Check Stdout Contains Regexp
    [Arguments]    @{expected}
    Check File Contains Regexp    ${STDOUT_FILE}    @{expected}

Get Syslog
    ${file} =    Get Output File    ${SYSLOG_FILE}
    [Return]    ${file}

Get Stderr
    ${file} =    Get Output File    ${STDERR_FILE}
    [Return]    ${file}

Get Stdout
    ${file} =    Get Output File    ${STDOUT_FILE}
    [Return]    ${file}

Syslog Should Contain Match
    [Arguments]    @{expected}
    File Should Contain Match    ${SYSLOG FILE}    @{expected}

Check Syslog Contains
    [Arguments]    @{expected}
    Check File Contains    ${SYSLOG_FILE}    @{expected}

Check Syslog Does Not Contain
    [Arguments]    @{expected}
    Check File Does Not Contain    ${SYSLOG_FILE}    @{expected}

Check Syslog Matches Regexp
    [Arguments]    @{expected}
    Check File Matches Regexp    ${SYSLOG_FILE}    @{expected}

Check Syslog Contains Regexp
    [Arguments]    @{expected}
    Check File Contains Regexp    ${SYSLOG_FILE}    @{expected}

Check Names
    [Arguments]    ${item}    ${name}    ${longprefix}=
    Should Be Equal    ${item.name}    ${name}
    Should Be Equal    ${item.longname}    ${longprefix}${name}

Is Valid Timestamp
    [Arguments]    ${time}
    Log    ${time}
    Should Not Be Equal    ${time}    ${None}
    Should Match Regexp    ${time}    20\\d{6} \\d{2}:\\d{2}:\\d{2}\\.\\d{3}    Not valid timestamp

Is Valid Elapsed Time
    [Arguments]    ${time}
    Log    ${time}
    Should Be True    isinstance(${time}, int) and ${time} >= 0    Not valid elapsed time

Previous test should have passed
    [Arguments]    ${name}
    Should be equal    ${PREV TEST NAME}    ${name}
    Should be equal    ${PREV TEST STATUS}    PASS

Get Stat Nodes
    [Arguments]    ${type}    ${output}=
    ${output} =    Set Variable If    "${output}"    ${output}    ${OUTFILE}
    ${nodes} =    Get Elements    ${output}    statistics/${type}/stat
    [Return]    ${nodes}

Get Tag Stat Nodes
    [Arguments]    ${output}=
    ${nodes} =    Get Stat Nodes    tag    ${output}
    [Return]    ${nodes}

Get Total Stat Nodes
    [Arguments]    ${output}=
    ${nodes} =    Get Stat Nodes    total    ${output}
    [Return]    ${nodes}

Get Suite Stat Nodes
    [Arguments]    ${output}=
    ${nodes} =    Get Stat Nodes    suite    ${output}
    [Return]    ${nodes}

Tag Statistics Should Be
    [Arguments]    ${tag}    ${pass}    ${fail}
    Log    ${tag.text}
    Should Be Equal As Integers    ${tag.attrib['pass']}    ${pass}
    Should Be Equal As Integers    ${tag.attrib['fail']}    ${fail}

Test And All Keywords Should Have Passed
    [Arguments]    ${name}=${TESTNAME}
    ${tc} =    Check Test Case    ${name}
    All Keywords Should Have Passed    ${tc}

All Keywords Should Have Passed
    [Arguments]    ${tc or kw}
    @{kws} =    Set Variable    ${tc or kw.kws}
    : FOR    ${kw}    IN    @{kws}
    \    Should Be Equal    ${kw.status}    PASS
    \    All Keywords Should Have Passed    ${kw}

Make test non-critical if
    [Arguments]    ${condition}
    Run Keyword If    ${condition}    Remove Tags    regression

Set PYTHONPATH
    [Arguments]    @{values}
    ${value} =    Catenate    SEPARATOR=${:}    @{values}
    Set Environment Variable    PYTHONPATH    ${value}
    Set Environment Variable    JYTHONPATH    ${value}
    Set Environment Variable    IRONPYTHONPATH    ${value}

Reset PYTHONPATH
    Remove Environment Variable    PYTHONPATH
    Remove Environment Variable    JYTHONPATH
    Remove Environment Variable    IRONPYTHONPATH
