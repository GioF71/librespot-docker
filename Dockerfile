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
RUN apt-get install -y git 
RUN apt-get install -y build-essential
RUN apt-get install -y libasound2-dev
RUN apt-get install -y curl
RUN apt-get install -y pkg-config
#RUN apt-get install -y cargo

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN rustup component add rustfmt
RUN rustup component add clippy
# DNS-SD
#RUN apt-get install -y libavahi-compat-libdnssd-dev pkg-config

RUN mkdir -p /app/source
WORKDIR /app/source

RUN git clone https://github.com/librespot-org/librespot.git
WORKDIR /app/source/librespot

RUN ls -la

RUN which cargo

RUN /usr/bin/cargo build --release --no-default-features --features alsa-backend