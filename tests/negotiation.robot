*** Settings ***
Suite Setup       Run Tests    ${EMPTY}    negotiation.robot
Resource          telnet_resource.robot

*** Test Cases ***
Binary transmission is refused
    Check Test Case    ${TEST NAME}

Other options are refused
    Check Test Case    ${TEST NAME}
