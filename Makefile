.PHONY: check docs package start_telnet stop_telnet upload

container_name := telnetlib-telnet

docs:
	mkdir -p doc
	libdoc src/TelnetLibrary.py doc/TelnetLibrary.html

package:
	$(RM) -r dist
	python3 -m pip install --upgrade build
	python3 -m build

upload:
	@if [ ! -d dist ]; then \
		echo "error: no 'dist/', run 'make package' first."; \
	    exit 1; \
	fi
	python3 -m pip install --upgrade twine
	python3 -m twine upload --repository testpypi dist/*

check: start_telnet
	TEMPDIR=$$PWD/tmp robot --pythonpath testresources tests/

start_telnet:
	@# build container if it doesn't exist
	@if [ -z "$$(docker images --quiet telnet-server)" ]; then \
	    echo 'Building Docker container with telnet server...'; \
	    docker build -t telnet-server testresources; \
	fi
	@# start container if it's not running
	@if [ -z "$$(docker ps --quiet --filter=name=$(container_name))" ]; then \
	    echo 'Starting Docker container with telnet server...'; \
	    docker run --detach \
	               --rm \
	               --network=host \
	               --name $(container_name) \
	               telnet-server > /dev/null; \
	fi

stop_telnet:
	@# stop container if it's running
	@if [ -n "$$(docker ps --quiet --filter=name=$(container_name))" ]; then \
	    echo 'Stopping Docker container with telnet server...'; \
	    docker container stop $(container_name) > /dev/null; \
	fi
