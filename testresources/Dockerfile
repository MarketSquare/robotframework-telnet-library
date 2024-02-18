FROM debian:buster

RUN apt-get update && \
    apt install -y --no-install-recommends telnetd xinetd update-inetd python && \
    apt autoremove -y && \
    apt autoclean -y && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --home-dir /home/test --shell /bin/bash test && \
    echo 'PS1='\''\u@\H \W \$ '\' >> /home/test/.bash_profile && \
    echo 'export LC_ALL=C.UTF-8' >> /home/test/.bash_profile && \
    echo test:test | chpasswd && \
    echo "# default: on \n \
    service telnet \n \
    { \n \
      disable = no \n \
      flags           = REUSE \n \
      socket_type     = stream \n \
      wait            = no \n \
      user            = root \n \
      server          = /usr/sbin/in.telnetd \n \
      log_on_failure  += USERID \n \
    }" | tee -a /etc/xinetd.d/telnet && \
    rm -f /etc/securetty

ENTRYPOINT ["xinetd"]
CMD ["-dontfork", "-stayalive"]
