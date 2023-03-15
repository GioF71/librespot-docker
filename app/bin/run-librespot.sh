#!/bin/bash

echo "run-librespot.sh"

DEFAULT_STARTUP_DELAY_SEC=0

declare -A file_dict

source read-file.sh
source get-value.sh

CREDENTIALS_FILE=/user/config/credentials.txt
if [ -f "$CREDENTIALS_FILE" ]; then
    read_file $CREDENTIALS_FILE
    SPOTIFY_USERNAME=$(get_value "SPOTIFY_USERNAME" $PARAMETER_PRIORITY)
    SPOTIFY_PASSWORD=$(get_value "SPOTIFY_PASSWORD" $PARAMETER_PRIORITY)
fi

CMD_LINE="/usr/bin/librespot"

DEFAULT_UID=1000
DEFAULT_GID=1000

if [ -z "${PUID}" ]; then
  PUID=$DEFAULT_UID;
  echo "Setting default value for PUID: ["$PUID"]"
fi

if [ -z "${PGID}" ]; then
  PGID=$DEFAULT_GID;
  echo "Setting default value for PGID: ["$PGID"]"
fi

USER_NAME=librespot-user
GROUP_NAME=librespot-group

HOME_DIR=/home/$USER_NAME

### create home directory and ancillary directories
if [ ! -d "$HOME_DIR" ]; then
  echo "Home directory [$HOME_DIR] not found, creating."
  mkdir -p $HOME_DIR
  chown -R $PUID:$PGID $HOME_DIR
  ls -la $HOME_DIR -d
  ls -la $HOME_DIR
fi

### create group
if [ ! $(getent group $GROUP_NAME) ]; then
  echo "group $GROUP_NAME does not exist, creating..."
  groupadd -g $PGID $GROUP_NAME
else
  echo "group $GROUP_NAME already exists."
fi

### create user
if [ ! $(getent passwd $USER_NAME) ]; then
  echo "user $USER_NAME does not exist, creating..."
  useradd -g $PGID -u $PUID -s /bin/bash -M -d $HOME_DIR $USER_NAME
  usermod -a -G audio $USER_NAME
  id $USER_NAME
  echo "user $USER_NAME created."
else
  echo "user $USER_NAME already exists."
fi

PULSE_CLIENT_CONF="/etc/pulse/client.conf"

echo "cat /app/assets/pulse-client-template.conf"
cat /app/assets/pulse-client-template.conf

echo "Creating pulseaudio configuration file $PULSE_CLIENT_CONF..."
cp /app/assets/pulse-client-template.conf $PULSE_CLIENT_CONF
sed -i 's/PUID/'"$PUID"'/g' $PULSE_CLIENT_CONF
cat $PULSE_CLIENT_CONF


if [ -n "$SPOTIFY_USERNAME" ]; then
    CMD_LINE="$CMD_LINE --username '$SPOTIFY_USERNAME'"
fi

if [ -n "$SPOTIFY_PASSWORD" ]; then
    CMD_LINE="$CMD_LINE --password '$SPOTIFY_PASSWORD'"
fi

if [ -n "$BACKEND" ]; then
    CMD_LINE="$CMD_LINE --backend $BACKEND"
fi

if [ -n "$BITRATE" ]; then
    CMD_LINE="$CMD_LINE --bitrate $BITRATE"
fi

if [ -n "$INITIAL_VOLUME" ]; then
    CMD_LINE="$CMD_LINE --initial-volume $INITIAL_VOLUME"
fi

if [ -n "$DEVICE_NAME" ]; then
    CMD_LINE="$CMD_LINE --name $DEVICE_NAME"
fi

if [ -n "$DEVICE_TYPE" ]; then
    CMD_LINE="$CMD_LINE --device-type $DEVICE_TYPE"
fi

if [ -n "$DEVICE" ]; then
    CMD_LINE="$CMD_LINE --device $DEVICE"
fi

if [ -n "$FORMAT" ]; then
    CMD_LINE="$CMD_LINE --format $FORMAT"
fi

if [ "${ENABLE_CACHE^^}" = "Y" ]; then
  CMD_LINE="$CMD_LINE --cache /data/cache"
fi 

if [ "${ENABLE_SYSTEM_CACHE^^}" = "Y" ]; then
  CMD_LINE="$CMD_LINE --system-cache /data/system-cache"
fi

if [ -n "$CACHE_SIZE_LIMIT" ]; then
    CMD_LINE="$CMD_LINE --cache-size-limit $CACHE_SIZE_LIMIT"
fi

if [ "${DISABLE_AUDIO_CACHE^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --disable-audio-cache"
fi

if [ "${DISABLE_CREDENTIAL_CACHE^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --disable-credential-cache"
fi

if [ -n "$MIXER" ]; then
    CMD_LINE="$CMD_LINE --mixer $MIXER"
fi

if [ -n "$ALSA_MIXER_CONTROL" ]; then
    CMD_LINE="$CMD_LINE --alsa-mixer-control '$ALSA_MIXER_CONTROL'"
fi

if [ -n "$ALSA_MIXER_DEVICE" ]; then
    CMD_LINE="$CMD_LINE --alsa-mixer-device '$ALSA_MIXER_DEVICE'"
fi

if [ -n "$ALSA_MIXER_INDEX" ]; then
    CMD_LINE="$CMD_LINE --alsa-mixer-index $ALSA_MIXER_INDEX"
fi

if [ "${QUIET^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --quiet"
fi

if [ "${VERBOSE^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --verbose"
fi

if [ -n "$PROXY" ]; then
    CMD_LINE="$CMD_LINE --proxy $PROXY"
fi

if [ -n "$AP_PORT" ]; then
    CMD_LINE="$CMD_LINE --ap-port $AP_PORT"
fi

if [ "${DISABLE_DISCOVERY^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --disable-discovery"
fi

if [ -n "$DITHER" ]; then
    CMD_LINE="$CMD_LINE --dither $DITHER"
fi

if [ -n "$ZEROCONF_PORT" ]; then
    CMD_LINE="$CMD_LINE --zeroconf-port $ZEROCONF_PORT"
fi

if [ "${ENABLE_VOLUME_NORMALISATION^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --enable-volume-normalisation"
fi

if [ -n "$NORMALISATION_METHOD" ]; then
    CMD_LINE="$CMD_LINE --normalisation-method $NORMALISATION_METHOD"
fi

if [ -n "$NORMALISATION_GAIN_TYPE" ]; then
    CMD_LINE="$CMD_LINE --normalisation-gain-type $NORMALISATION_GAIN_TYPE"
fi

if [ -n "$NORMALISATION_PREGAIN" ]; then
    CMD_LINE="$CMD_LINE --normalisation-pre-gain $NORMALISATION_PREGAIN"
fi

if [ -n "$NORMALISATION_THRESHOLD" ]; then
    CMD_LINE="$CMD_LINE --normalisation-threshold $NORMALISATION_THRESHOLD"
fi

if [ -n "$NORMALISATION_ATTACK" ]; then
    CMD_LINE="$CMD_LINE --normalisation-attack $NORMALISATION_ATTACK"
fi

if [ -n "$NORMALISATION_RELEASE" ]; then
    CMD_LINE="$CMD_LINE --normalisation-release $NORMALISATION_RELEASE"
fi

if [ -n "$NORMALISATION_KNEE" ]; then
    CMD_LINE="$CMD_LINE --normalisation-tree $NORMALISATION_KNEE"
fi

if [ -n "$VOLUME_CTRL" ]; then
    CMD_LINE="$CMD_LINE --volume-ctrl $VOLUME_CTRL"
fi

if [ -n "$VOLUME_RANGE" ]; then
    CMD_LINE="$CMD_LINE --volume-range $VOLUME_RANGE"
fi

if [ "${AUTOPLAY^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --autoplay"
fi

if [ "${DISABLE_GAPLESS^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --disable-gapless"
fi

if [ "${PASSTHROUGH^^}" = "Y" ]; then
    CMD_LINE="$CMD_LINE --passthrough"
fi

if [[ -z "${LOG_COMMAND_LINE}" || "${LOG_COMMAND_LINE^^}" = "Y" ]]; then
    ur=$(printf '*%.0s' $(seq 1 ${#SPOTIFY_USERNAME}))
    pr=$(printf '*%.0s' $(seq 1 ${#SPOTIFY_PASSWORD}))
    some_asterisks=$(printf '*%.0s' $(seq 1 16))

    safe=$CMD_LINE
    safe=$(echo "${safe/"$SPOTIFY_USERNAME"/"$some_asterisks"}")
    safe=$(echo "${safe/"$SPOTIFY_PASSWORD"/"$some_asterisks"}")
    echo "Command Line: [$safe]"

    #echo "Command Line: ["$CMD_LINE"]"

fi

if [ "$BACKEND" = "pulseaudio" ]; then
  su - $USER_NAME -c "$CMD_LINE";
else
  eval $CMD_LINE;
fi

