import socket
import threading
import time


class negotiation_server:
    """One-connection Telnet server for option negotiation tests.

    Sends the given telnet commands to the client that connects and records
    everything the client sends back.
    """

    ROBOT_LIBRARY_SCOPE = 'TEST'

    def __init__(self):
        self._listener = None
        self._received = b''
        self._thread = None

    def start_negotiation_server(self, *commands):
        """Starts listening on a free localhost port and returns the port.

        ``commands`` are sent as bytes, each given as space separated
        decimal values such as ``255 253 0`` for IAC DO BINARY.
        """
        self._listener = socket.create_server(('localhost', 0))
        data = b''.join(bytes(int(b) for b in c.split()) for c in commands)
        self._thread = threading.Thread(target=self._serve, args=(data,),
                                        daemon=True)
        self._thread.start()
        return self._listener.getsockname()[1]

    def _serve(self, data):
        conn, _ = self._listener.accept()
        with conn:
            conn.sendall(data)
            conn.settimeout(0.5)
            end = time.time() + 2
            while time.time() < end:
                try:
                    chunk = conn.recv(1024)
                except socket.timeout:
                    continue
                if not chunk:
                    break
                self._received += chunk
        self._listener.close()

    def received_should_be(self, *commands):
        """Waits for the server to finish and checks what the client sent."""
        self._thread.join()
        expected = b''.join(bytes(int(b) for b in c.split()) for c in commands)
        if self._received != expected:
            raise AssertionError('Client sent %r, expected %r'
                                 % (self._received, expected))
