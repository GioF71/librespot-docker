#!/bin/bash

source files.sh

# errors

# 2 missing credentials fileq

set -e

if [ ! -f $LIBRESPOT_PULSE_ENV_FILE ]; then
    echo "File $LIBRESPOT_PULSE_ENV_FILE is missing!"
    echo "The contents of $LIBRESPOT_PULSE_ENV_FILE should be like the following:"
    cat $LIBRESPOT_PULSE_ENV_FILE_SAMPLE
    exit 2
fi

mkdir -p $SYSTEMD_USER_DIRECTORY
cp $SYSTEMD_SERVICE_FILE $SYSTEMD_USER_DIRECTORY/

mkdir -p $LIBRESPOT_PULSE_CONFIG_DIR
cp $LIBRESPOT_PULSE_ENV_FILE $LIBRESPOT_PULSE_CONFIG_DIR/
#echo "contents of $LIBRESPOT_PULSE_CONFIG_DIR/$LIBRESPOT_PULSE_ENV_FILE:"
#cat $LIBRESPOT_PULSE_CONFIG_DIR/$LIBRESPOT_PULSE_ENV_FILE

systemctl --user daemon-reload
systemctl --user enable librespot-pulse
