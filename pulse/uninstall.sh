#!/bin/bash

systemctl --user stop librespot-pulse
systemctl --user disable librespot-pulse

source files.sh

# cleanup
#if [ -f $SERVICE_ENV_FILE ]; then
#    echo "removing $SERVICE_ENV_FILE"
#    rm $SERVICE_ENV_FILE
#fi

env_file_toremove=$SERVICE_DIRECTORY/SERVICE_ENV_FILE
if [ -f $env_file_toremove ]; then
    echo "removing $env_file_toremove"
    rm $env_file_toremove
fi

srv_file_toremove=$SERVICE_DIRECTORY/$SERVICE_ENV_FILE

if [ -f $srv_file_toremove ]; then
    echo "removing $srv_file_toremove"
    rm $srv_file_toremove
fi

env_file_to_remove=$LIBRESPOT_PULSE_CONFIG_DIR/$LIBRESPOT_PULSE_ENV_FILE
if [ -f $env_file_to_remove ]; then
    echo "removing $env_file_to_remove"
    rm $env_file_to_remove
    rm -d $LIBRESPOT_PULSE_CONFIG_DIR/
fi

systemctl --user reset-failed
systemctl --user daemon-reload


