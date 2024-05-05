### Regenerating documentation

To be run after changing documentation comments:

```bash
make docs
```

### Running tests

Automated build/start of Docker container with Telnet (leaves it running):

```bash
make check
```

To start/stop the Docker container manually:

```bash
# builds and starts Docker container with Telnet server explicilty
make start_telnet

# also builds and starts Docker container for tests if necessary
make check

# stops Docker container if it's running
make stop_telnet
```
