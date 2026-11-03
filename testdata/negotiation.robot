*** Settings ***
Library           TelnetLibrary
Library           negotiation_server.py
Test Teardown     Close All Connections

*** Test Cases ***
Binary transmission is refused
    ${port} =    Start negotiation server    255 253 0    255 251 0
    Open Connection    localhost    port=${port}
    Sleep    0.2s    Give the server time to send.
    Read
    Close Connection
    Received should be    255 252 0    255 254 0

Other options are refused
    ${port} =    Start negotiation server    255 253 3    255 251 3
    Open Connection    localhost    port=${port}
    Sleep    0.2s    Give the server time to send.
    Read
    Close Connection
    Received should be    255 252 3    255 254 3
