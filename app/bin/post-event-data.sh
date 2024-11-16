#!/bin/bash

# read url input parameter
while [ $# -gt 0 ]; do
  case "$1" in
    --url=*)
      endpoint_url="${1#*=}"
      ;;
  esac
  shift
done

# post current event data the given endpoint URL
curl -X POST \
-s \
-H "Content-Type: application/json" \
-d '{
    "PLAYER_EVENT": "'"$PLAYER_EVENT"'",
    "TRACK_ID": "'"$TRACK_ID"'",
    "URI": "'"$URI"'",
    "NAME": "'"$NAME"'",
    "COVERS": "'"${COVERS//$'\n'/,}"'",
    "LANGUAGE": "'"$LANGUAGE"'",
    "DURATION_MS": "'"$DURATION_MS"'",
    "NAME": "'"$NAME"'",
    "IS_EXPLICIT": "'"$IS_EXPLICIT"'",
    "ITEM_TYPE": "'"$ITEM_TYPE"'",
    "ARTISTS": "'"$ARTISTS"'",
    "ALBUM_ARTISTS": "'"$ALBUM_ARTISTS"'",
    "ALBUM": "'"$ALBUM"'",
    "NUMBER": "'"$NUMBER"'",
    "DISC_NUMBER": "'"$DISC_NUMBER"'",
    "DESCRIPTION": "'"$DESCRIPTION"'",
    "PUBLISH_TIME": "'"$PUBLISH_TIME"'",
    "SHOW_NAME": "'"$SHOW_NAME"'",
    "POSITION_MS": "'"$POSITION_MS"'",
    "CONNECTION_ID": "'"$CONNECTION_ID"'",
    "USER_NAME": "'"$USER_NAME"'",
    "CLIENT_ID": "'"$CLIENT_ID"'",
    "CLIENT_NAME": "'"$CLIENT_NAME"'",
    "CLIENT_BRAND_NAME": "'"$CLIENT_BRAND_NAME"'",
    "CLIENT_MODEL_NAME": "'"$CLIENT_MODEL_NAME"'",
    "VOLUME": "'"$VOLUME"'",
    "SHUFFLE": "'"$SHUFFLE"'",
    "REPEAT": "'"$REPEAT"'",
    "AUTO_PLAY": "'"$AUTO_PLAY"'",
    "FILTER": "'"$FILTER"'",
    "SINK_STATUS": "'"$SINK_STATUS"'"
}' \
$endpoint_url

