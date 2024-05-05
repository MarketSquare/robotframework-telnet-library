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

### Building a PyPI package

Prior to building the command below removes `dist/` directory so that one
doesn't need to specify version to upload later.

This automatically installs/upgrades required dependencies so enter virtualenv
if you don't otherwise need them:

```bash
make package
```

### Uploading a PyPI package

This should be done after building a package or you'll get a reminder about it.
The command uploads whatever `dist/` contains, which is why packaging removes
the directory with all its contents.

This automatically installs/upgrades required dependencies so enter virtualenv
if you don't otherwise need them:

```bash
make upload
```

It will ask for <https://pypi.org/> API token interactively by default, which
can be changed by [storing the token in configuration file][pypirc].

[pypirc]: https://packaging.python.org/en/latest/specifications/pypirc/#using-a-pypi-token
