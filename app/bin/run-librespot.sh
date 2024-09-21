#!/bin/bash

DIRECTORY_NAME_DATA_CACHE=/data/cache
DIRECTORY_NAME_DATA_SYSTEM_CACHE=/data/system-cache

current_user_id=$(id -u)
echo "Current user id is [$current_user_id]"

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

echo "BACKEND=[${BACKEND}]"

if [[ $current_user_id -eq 0 ]]; then
    if [[ "${BACKEND}" == "pulseaudio" ]]; then
        echo "Backend is [${BACKEND}], user mode is enforced"
        if [[ -z "${PUID}" ]]; then
            PUID=$DEFAULT_UID;
            echo "Setting default value for PUID: ["$PUID"]"
            if [[ -z "${PGID}" ]]; then
                PGID=$DEFAULT_GID;
                echo "Also setting default value for PGID: ["$PGID"]"
            fi
        fi
        if [[ -z "${PGID}" ]]; then
            PGID=$DEFAULT_GID;
            echo "Setting default value for PGID: ["$PGID"]"
        fi
    fi
    USER_NAME=librespot-user
    GROUP_NAME=librespot-group
    HOME_DIR=/home/$USER_NAME
    # handle user mode
    if [[ -n "${PUID}" ]]; then
        if [[ -z "${PGID}" ]]; then
            echo "PUID is set to [${PUID}] but PGID is empty, using PUID"
            PGID=${PUID}
        fi
        echo "User mode with PUID=[${PUID}] PGID=[${PGID}] AUDIO_GID=[${AUDIO_GID}]"
        echo "Ensuring user with uid:[${PUID}] gid:[${PGID}] exists ...";
        ### create group if it does not exist
        if [ ! $(getent group $PGID) ]; then
            echo "Group with gid [$PGID] does not exist, creating..."
            groupadd -g $PGID $GROUP_NAME
            echo "Group [$GROUP_NAME] with gid [$PGID] created."
        else
            GROUP_NAME=$(getent group $PGID | cut -d: -f1)
            echo "Group with gid [$PGID] name [$GROUP_NAME] already exists."
        fi
        ### create user if it does not exist
        if [ ! $(getent passwd $PUID) ]; then
            echo "User with uid [$PUID] does not exist, creating..."
            useradd -g $PGID -u $PUID -M $USER_NAME
            echo "User [$USER_NAME] with uid [$PUID] created."
        else
            USER_NAME=$(getent passwd $PUID | cut -d: -f1)
            echo "user with uid [$PUID] name [$USER_NAME] already exists."
            HOME_DIR="/home/$USER_NAME"
        fi
        ### create home directory
        if [ ! -d "$HOME_DIR" ]; then
            echo "Home directory [$HOME_DIR] not found, creating."
            mkdir -p $HOME_DIR
            echo ". done."
        fi
        echo "Setting ownership of [${HOME_DIR}] to [$USER_NAME:$GROUP_NAME] ..."
        chown -R $USER_NAME:$GROUP_NAME $HOME_DIR
        echo "Done."
        if [[ $PUID -ne 0 ]]; then
            if [ -z "${AUDIO_GID}" ]; then
                echo "WARNING: AUDIO_GID is mandatory for user mode and alsa backend"
                echo "WARNING: Ignore the previous warning if you set PGID to the ""audio"" group"
            else
                if [ $(getent group $AUDIO_GID) ]; then
                    echo "Alsa Mode - Group with gid $AUDIO_GID already exists"
                else
                    echo "Alsa Mode - Creating group with gid $AUDIO_GID"
                    groupadd -g $AUDIO_GID sq-audio
                fi
                echo "Alsa Mode - Adding $USER_NAME [$PUID] to gid [$AUDIO_GID]"
                AUDIO_GRP=$(getent group $AUDIO_GID | cut -d: -f1)
                echo "gid $AUDIO_GID -> group $AUDIO_GRP"
                usermod -a -G $AUDIO_GRP $USER_NAME
                echo "Alsa Mode - Successfully created user $USER_NAME:$GROUP_NAME [$PUID:$PGID])";
            fi
        else
            echo "PUID specifies the root user, not adding to the ""audio"" group"
        fi
        # set ownership on volumes
        echo "Setting ownership of volumes to [$USER_NAME:$GROUP_NAME] ..."
        chown -R $USER_NAME:$GROUP_NAME $DIRECTORY_NAME_DATA_CACHE
        chown -R $USER_NAME:$GROUP_NAME $DIRECTORY_NAME_DATA_SYSTEM_CACHE
        echo "Done."
    fi
    # preparing for pulseaudio
    if [[ "${BACKEND}" == "pulseaudio" ]]; then
        PULSE_CLIENT_CONF="/etc/pulse/client.conf"
        echo "cat /app/assets/pulse-client-template.conf"
        cat /app/assets/pulse-client-template.conf
        echo "Creating pulseaudio configuration file $PULSE_CLIENT_CONF..."
        cp /app/assets/pulse-client-template.conf $PULSE_CLIENT_CONF
        sed -i 's/PUID/'"$PUID"'/g' $PULSE_CLIENT_CONF
        cat $PULSE_CLIENT_CONF
    fi
fi

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
    CMD_LINE="$CMD_LINE --name '$DEVICE_NAME'"
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
    if [ -w "$DIRECTORY_NAME_DATA_CACHE" ]; then
        echo "Directory [$DIRECTORY_NAME_DATA_CACHE] is writable"
        CMD_LINE="$CMD_LINE --cache $DIRECTORY_NAME_DATA_CACHE"
    else
        echo "Directory [$DIRECTORY_NAME_DATA_CACHE] is not writable, creating in /tmp ..."
        mkdir -p /tmp/cache
        CMD_LINE="$CMD_LINE --cache /tmp/cache"
    fi
fi 

if [ "${ENABLE_SYSTEM_CACHE^^}" = "Y" ]; then
    if [ -w "$DIRECTORY_NAME_DATA_SYSTEM_CACHE" ]; then
        echo "Directory [$DIRECTORY_NAME_DATA_SYSTEM_CACHE] is writable"
        CMD_LINE="$CMD_LINE --system-cache $DIRECTORY_NAME_DATA_SYSTEM_CACHE"
    else
        echo "Directory [$DIRECTORY_NAME_DATA_SYSTEM_CACHE] is not writable, creating in /tmp ..."
        mkdir -p /tmp/system-cache
        CMD_LINE="$CMD_LINE --system-cache /tmp/system-cache"
    fi
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
    CMD_LINE="$CMD_LINE --normalisation-pregain $NORMALISATION_PREGAIN"
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
fi

if [[ $current_user_id -eq 0 ]]; then
    if [[ "${BACKEND}" == "pulseaudio" || -n "${PUID}" ]]; then
        echo "Running in user mode ..."
        exec su - $USER_NAME -c "$CMD_LINE"
    else
        echo "Running as root ..."
        eval "exec $CMD_LINE";
    fi
else
    echo "Running as uid: [$current_user_id] ..."
    eval "exec $CMD_LINE"
fi
