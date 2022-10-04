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
RUN apt-get install -y libasound2
RUN apt-get install -y alsa-utils

RUN apt-get -y install curl
RUN curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

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

ENV PUID ""
ENV PGID ""

VOLUME /data/cache
VOLUME /data/system-cache

COPY README.md /app/doc/

RUN mkdir -p /app/assets

COPY app/assets/pulse-client-template.conf /app/assets/

RUN which librespot

COPY app/bin/run-librespot.sh /app/bin/
RUN chmod u+x /app/bin/run-librespot.sh

WORKDIR /app/bin
ENTRYPOINT ["/app/bin/run-librespot.sh"]