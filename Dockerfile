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
#RUN apt-get upgrade -y
RUN apt-get install -y libasound2
RUN apt-get install -y alsa-utils
RUN apt-get install -y build-essential
RUN apt-get install -y libasound2-dev
RUN apt-get install -y libpulse-dev

#RUN cargo install librespot

RUN mkdir /src
WORKDIR /src
RUN git clone --branch master https://github.com/librespot-org/librespot.git
WORKDIR /src/librespot
RUN CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --release --no-default-features --features alsa-backend --features pulseaudio-backend
RUN rm -Rf /src

RUN rm -rf /var/lib/apt/lists/*

#FROM scratch
#COPY --from=BASE / /

LABEL maintainer="GioF71"
LABEL source="https://github.com/GioF71/librespot-docker"

ENV SPOTIFY_USERNAME ""
ENV SPOTIFY_PASSWORD ""

ENV BITRATE ""
ENV BACKEND ""

ENV INITIAL_VOLUME ""

ENV DEVICE_NAME ""
ENV DEVICE_TYPE ""

ENV DEVICE ""
ENV FORMAT ""

ENV ENABLE_CACHE ""
ENV ENABLE_SYSTEM_CACHE ""

ENV CACHE_SIZE_LIMIT ""

ENV DISABLE_AUDIO_CACHE ""
ENV DISABLE_CREDENTIAL_CACHE ""

ENV MIXER ""
ENV ALSA_MIXER_CONTROL ""
ENV ALSA_MIXER_DEVICE ""
ENV ALSA_MIXER_INDEX ""

ENV QUIET ""
ENV VERBOSE ""

ENV PROXY ""
ENV AP_PORT ""

ENV DISABLE_DISCOVERY ""

ENV DITHER ""

ENV ZEROCONF_PORT ""

ENV ENABLE_VOLUME_NORMALISATION ""
ENV NORMALISATION_METHOD ""
ENV NORMALISATION_GAIN_TYPE ""
ENV NORMALISATION_PREGAIN ""
ENV NORMALISATION_THRESHOLD ""
ENV NORMALISATION_ATTACK ""
ENV NORMALISATION_RELEASE ""
ENV NORMALISATION_KNEE ""

ENV VOLUME_CTRL ""
ENV VOLUME_RANGE ""

ENV AUTOPLAY ""
ENV DISABLE_GAPLESS ""
ENV PASSTHROUGH ""

ENV PUID ""
ENV PGID ""

ENV PARAMETER_PRIORITY ""
ENV LOG_COMMAND_LINE ""

ENV CARGO_HOME "/cargo-home"

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

RUN chmod u+x /app/bin/*.sh

WORKDIR /app/bin
ENTRYPOINT ["/app/bin/run-librespot.sh"]