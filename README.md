## TelnetLibrary for Robot Framework

This is a library providing communication over Telnet connections.

TelnetLibrary is Robot Framework's library that makes it possible to connect
to Telnet servers and execute commands on the opened connections with or without
terminal emulation.

This library used to be known as "Telnet standard library" of Robot Framework
until it was extracted out of it as a standalone extension.

### Installation

```bash
pip install robotframework-telnetlibrary
```

### Regenerating documentation

```bash
make docs
```

### Running tests

```bash
# builds and starts Docker container with Telnet server explicilty
make start_telnet

# also builds and starts Docker container for tests if necessary
make check

# stops Docker container if it's running
make stop_telnet
```

### License

Apache License 2.0
