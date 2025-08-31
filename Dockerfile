ARG RUST_IMAGE=""
ARG BASE_IMAGE=""
FROM ${RUST_IMAGE:-library/rust:slim} AS base

RUN mkdir -p /app/bin
RUN mkdir -p /app/conf
RUN mkdir -p /app/doc

# Add build dependencies
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y cmake
RUN apt-get install -y libclang-dev
RUN apt-get install -y libasound2-dev
RUN apt-get install -y libpulse-dev
RUN apt-get install -y libavahi-compat-libdnssd-dev
RUN apt-get install -y pkg-config

# runtime
RUN apt-get install -y libavahi-compat-libdnssd1

RUN apt-get install -y git

RUN mkdir /src
WORKDIR /src
RUN git clone --depth 1 --branch master-v0.7.0 https://github.com/GioF71/librespot.git
WORKDIR /src/librespot
RUN CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --release --no-default-features --features "native-tls alsa-backend pulseaudio-backend with-avahi with-dns-sd with-libmdns"
RUN cp /src/librespot/target/release/librespot /usr/bin/librespot
WORKDIR /

FROM ${BASE_IMAGE:-library/debian:stable-slim} AS intermediate

COPY --from=base /usr/bin/librespot /usr/bin/librespot

# Add runtime dependencies only
RUN apt-get update
RUN apt-get install -y libasound2-plugins
RUN apt-get install -y alsa-utils
RUN apt-get install -y --no-install-recommends pulseaudio-utils
RUN apt-get install -y ca-certificates
RUN apt-get install -y libavahi-compat-libdnssd1
RUN apt-get install -y curl
    
RUN	rm -rf /var/lib/apt/lists/*

FROM scratch
COPY --from=intermediate / /

LABEL maintainer="GioF71"
LABEL source="https://github.com/GioF71/librespot-docker"

ENV SPOTIFY_USERNAME=""
ENV SPOTIFY_PASSWORD=""

ENV BITRATE=""
ENV BACKEND=""

ENV INITIAL_VOLUME=""

ENV DEVICE_NAME=""
ENV DEVICE_TYPE=""

ENV DEVICE=""
ENV FORMAT=""

ENV ENABLE_CACHE=""
ENV ENABLE_SYSTEM_CACHE=""

ENV CACHE_SIZE_LIMIT=""

ENV DISABLE_AUDIO_CACHE=""
ENV DISABLE_CREDENTIAL_CACHE=""

ENV MIXER=""
ENV ALSA_MIXER_CONTROL=""
ENV ALSA_MIXER_DEVICE=""
ENV ALSA_MIXER_INDEX=""

ENV QUIET=""
ENV VERBOSE=""

ENV PROXY=""
ENV AP_PORT=""

ENV DISABLE_DISCOVERY=""

ENV DITHER=""

ENV ZEROCONF_PORT=""
ENV ZEROCONF_BACKEND=""

ENV ENABLE_VOLUME_NORMALISATION=""
ENV NORMALISATION_METHOD=""
ENV NORMALISATION_GAIN_TYPE=""
ENV NORMALISATION_PREGAIN=""
ENV NORMALISATION_THRESHOLD=""
ENV NORMALISATION_ATTACK=""
ENV NORMALISATION_RELEASE=""
ENV NORMALISATION_KNEE=""

ENV VOLUME_CTRL=""
ENV VOLUME_RANGE=""

ENV AUTOPLAY=""
ENV DISABLE_GAPLESS=""
ENV PASSTHROUGH=""

ENV PUID=""
ENV PGID=""
ENV AUDIO_GID=""

ENV PARAMETER_PRIORITY=""
ENV LOG_COMMAND_LINE=""

ENV ONEVENT_COMMAND=""
ENV ONEVENT_POST_ENDPOINT=""

ENV ENABLE_OAUTH=""

ENV CARGO_HOME "/cargo-home"
ENV ADDITIONAL_ARGUMENTS=""

VOLUME /data/cache
VOLUME /data/system-cache
VOLUME /user/config

VOLUME /cargo-home

COPY README.md /app/doc/

RUN mkdir -p /app/assets

COPY app/assets/pulse-client-template.conf /app/assets/

#RUN which librespot

COPY app/bin/run-librespot.sh /app/bin/
COPY app/bin/read-file.sh /app/bin/
COPY app/bin/get-value.sh /app/bin/
COPY app/bin/post-event-data.sh /app/bin/

RUN chmod u+x /app/bin/*.sh

WORKDIR /app/bin
ENTRYPOINT ["/app/bin/run-librespot.sh"]
