#!/bin/bash

source read-file.sh
source get-value.sh

declare -A file_dict
credentials_file="sample.txt"


SPOTIFY_USERNAME="pippo_env"

SPOTIFY_PASSWORD1="pluto_env_1"
SPOTIFY_PASSWORD3="pluto_env_3"
SPOTIFY_PASSWORD4="pluto_env_4"


#PARAMETER_PRIORITY="env"

if [ -f "$credentials_file" ]; then
    read_file $credentials_file
    # Print out the dict
    for key in "${!file_dict[@]}"; do
        printf '%s=%s\n' "$key" "${file_dict[$key]}"
    done
    pw1=$(get_value "SPOTIFY_PASSWORD1")
    pw2=$(get_value "SPOTIFY_PASSWORD2")
    pw3=$(get_value "SPOTIFY_PASSWORD3")
    echo "pw1 = $pw1"
    echo "pw2 = $pw2"
    echo "pw3 = $pw3"
    pw4_prio_env=$(get_value "SPOTIFY_PASSWORD4" env)
    pw4_prio_file=$(get_value "SPOTIFY_PASSWORD4" file)
    echo "pw4_prio_env = $pw4_prio_env"
    echo "pw4_prio_file = $pw4_prio_file"

    phrase="This phrase contains credentials $SPOTIFY_USERNAME $SPOTIFY_PASSWORD1"
    echo "unsafe=[$phrase]"

    ur=$(printf '*%.0s' $(seq 1 ${#SPOTIFY_USERNAME}))
    pr=$(printf '*%.0s' $(seq 1 ${#SPOTIFY_PASSWORD1}))

    safe=$phrase
    safe=$(echo "${safe/"$SPOTIFY_USERNAME"/"$ur"}")
    safe=$(echo "${safe/"$SPOTIFY_PASSWORD1"/"$pr"}")
    echo "safe: [$safe]"
else
    echo "File not found"
    exit 2
fi


