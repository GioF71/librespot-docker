ARG BASE_IMAGE
FROM rust:bullseye AS BUILD
ARG USE_APT_PROXY
ARG USE_BRANCH

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

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libasound2-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libpulse-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pkg-config
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libavahi-compat-libdnssd-dev

# Check cargo is visible
RUN cargo --help

RUN cargo install librespot 

RUN /usr/local/cargo/bin/librespot -h

ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS RUNNER
ARG USE_APT_PROXY

RUN mkdir -p /app/bin
RUN mkdir -p /app/conf
RUN mkdir -p /app/doc

COPY --from=BUILD /usr/local/cargo/bin/librespot /app/bin/librespot
COPY app/conf/01-apt-proxy /app/conf/

RUN if [ "$USE_APT_PROXY" = "Y" ]; then \
	echo "Using apt proxy"; \
	cp /app/conf/01-apt-proxy /etc/apt/apt.conf.d/; \
	cat /etc/apt/apt.conf.d/01-apt-proxy; \
	else \
	echo "Building without proxy"; \
	fi

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y pulseaudio --no-install-recommends && \
	apt-get install -y libasound2 --no-install-recommends && \
	apt-get autoremove -y && \
	rm -rf "/var/lib/apt/lists/*"

ENV SPOTIFY_USERNAME ""
ENV SPOTIFY_PASSWORD ""

ENV BITRATE ""
ENV BACKEND ""

ENV INITIAL_VOLUME ""

ENV DEVICE_NAME ""
ENV DEVICE_TYPE ""

ENV DEVICE ""

ENV PUID ""
ENV PGID ""

RUN mkdir -p /app/assets

COPY app/assets/pulse-client-template.conf /app/assets/

COPY app/bin/run-librespot.sh /app/bin/
RUN chmod u+x /app/bin/run-librespot.sh

WORKDIR /app/bin
ENTRYPOINT ["/app/bin/run-librespot.sh"]
