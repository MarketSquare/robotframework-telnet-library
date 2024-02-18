A library providing communication over Telnet connections.

Telnet Library is Robot Framework's library that makes it possible to connect
to Telnet servers and execute commands on the opened connections.

This library used to be known as Telnet standard library of Robot Framework
until it was extracted out of it as a standalone extension.

***

Run a local Telnet server for tests:

    docker build -t telnet-server testresources
    docker run -itd --rm --network=host telnet-server

Execute tests:

    TEMPDIR=$PWD/tmp robot --pythonpath -variable-file "testresources/interpreter.py;$(which python3)" tests/connections.robot
