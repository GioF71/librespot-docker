#!/bin/sh

systemctl --user daemon-reload
systemctl --user stop librespot-pulse
systemctl --user start librespot-pulse


