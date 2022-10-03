ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS BUILD
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

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl
RUN apt-get install -y git 
RUN apt-get install -y build-essential
RUN apt-get install -y libasound2-dev
RUN apt-get install -y libpulse-dev
RUN apt-get install -y pkg-config
RUN apt-get install -y libavahi-compat-libdnssd-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN mkdir -p /app/source

WORKDIR /app/source
RUN if [ -n "${USE_BRANCH}" ]; then \
	echo "Using branch [$USE_BRANCH]"; \
	git clone https://github.com/librespot-org/librespot.git --branch $USE_BRANCH; \
	else \
	echo "Using default branch"; \
	git clone https://github.com/librespot-org/librespot.git; \
	fi
WORKDIR /app/source/librespot

RUN ls -la

ENV PATH="/root/.cargo/bin:${PATH}"

# Check cargo is visible
RUN cargo --help

RUN cargo build --release --no-default-features --features "alsa-backend pulseaudio-backend"

RUN ./target/release/librespot -h
RUN cp ./target/release/librespot /app/bin/librespot

ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS RUNNER
ARG USE_APT_PROXY

RUN mkdir -p /app/bin
RUN mkdir -p /app/conf
RUN mkdir -p /app/doc

COPY --from=BUILD /app/bin/librespot /app/bin/librespot
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
