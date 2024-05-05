*** Settings ***
Library           OperatingSystem
Library           Process
Library           String
Library           TestCheckerLibrary
Variables         test_variables.py    # Provides DATADIR
Variables         ${DATADIR}/telnet_variables.py

*** Variables ***
${OUTDIR}         %{TEMPDIR}${/}output
${OUTFILE}        ${OUTDIR}${/}output.xml
${SET SYSLOG}     True
${SYSLOG FILE}    ${OUTDIR}${/}syslog.txt
${SYSLOG LEVEL}   INFO
${STDOUT FILE}    ${OUTDIR}${/}stdout.txt
${STDERR FILE}    ${OUTDIR}${/}stderr.txt
${SUITE}          Set by TestCheckerLibrary.Process Output
${RUNNER DEFAULTS}
...               --ConsoleColors OFF
...               --output ${OUTFILE}
...               --report NONE
...               --log NONE
...               --ConsoleMarkers OFF
...               --PYTHONPATH "${CURDIR}${/}..${/}src"

*** Keywords ***
Run Tests
    [Arguments]    ${options}=    ${sources}=    ${default options}=${RUNNER DEFAULTS}    ${output}=${OUTFILE}
    [Documentation]    *OUTDIR:* file://${OUTDIR} (regenerated for every run)
    ${result} =    Execute    ${INTERPRETER.runner}   ${options}    ${sources}    ${default options}
    Log Many    RC: ${result.rc}    STDERR:\n${result.stderr}    STDOUT:\n${result.stdout}
    Process Output    ${output}
    RETURN    ${result}

Execute
    [Arguments]    ${executor}    ${options}    ${sources}    ${default options}=
    Set Execution Environment
    @{arguments} =    Get Execution Arguments    ${options}    ${sources}    ${default options}
    ${result} =    Run Process    @{executor}    @{arguments}
    ...    stdout=${STDOUTFILE}    stderr=${STDERRFILE}    output_encoding=SYSTEM
    ...    timeout=5min    on_timeout=terminate
    RETURN    ${result}

Get Execution Arguments
    [Arguments]    ${options}    ${sources}    ${default options}
    @{options} =    Split command line    --outputdir ${OUTDIR} ${default options} ${options}
    @{sources} =    Split command line    ${sources}
    @{sources} =    Join Paths    ${DATADIR}    @{sources}
    RETURN    @{options}    @{sources}

Set Execution Environment
    Remove Directory    ${OUTDIR}    recursive
    Create Directory    ${OUTDIR}
    IF    ${SET SYSLOG}
        Set Environment Variable    ROBOT_SYSLOG_FILE    ${SYSLOG FILE}
        Set Environment Variable    ROBOT_SYSLOG_LEVEL    ${SYSLOG LEVEL}
    END
