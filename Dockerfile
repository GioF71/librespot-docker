ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG USE_APT_PROXY

RUN mkdir -p /app/bin
RUN mkdir -p /app/conf
RUN mkdir -p /app/doc

COPY app/conf/01-apt-proxy /app/conf/

RUN if [ "$USE_APT_PROXY" = "Y" ]; then \
	echo "Using apt proxy"; \
	cp /app/conf/01-apt-proxy /etc/apt/apt.conf.d/; \
	cat /etc/apt/apt.conf.d/01-apt-proxy; \
	else \
	echo "Building without proxy"; \
	fi

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get -y install curl
RUN curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

RUN which librespot

#ENTRYPOINT ["/app/bin/run-librepot.sh"]
ENTRYPOINT ["/usr/bin/librespot"]