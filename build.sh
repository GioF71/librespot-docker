#!/bin/bash

declare -A base_images

base_images[rust]=library/rust:latest
base_images[rust-bullseye]=library/rust:bullseye
base_images[rust-slim-bullseye]=library/rust:slim-bullseye

DEFAULT_BASE_IMAGE=rust
DEFAULT_TAG=local
DEFAULT_USE_PROXY=N
DEFAULT_BRANCH=master

tag=$DEFAULT_TAG
use_proxy=$DEFAULT_USE_PROXY

while getopts b:t:p:v: flag
do
    case "${flag}" in
        b) base_image=${OPTARG};;
        t) tag=${OPTARG};;
        p) proxy=${OPTARG};;
        v) select_branch=${OPTARG};;
    esac
done

echo "base_image: $base_image";
echo "tag: $tag";
echo "proxy: $proxy";
echo "branch: $select_branch"

if [ -z "${base_image}" ]; then
  base_image=$DEFAULT_BASE_IMAGE
fi

if [ -z "${proxy}" ]; then
  use_proxy="N"
else
  use_proxy=$proxy
fi

if [ -z "${tag}" ]; then
    tag="latest"
fi

if [[ -z ${base_images[$base_image]} ]]; then
  echo "Image for ["$base_image"] not found"
  select_base_image=${base_images[$DEFAULT_BASE_IMAGE]}
else
  select_base_image=${base_images[$base_image]}
fi

echo "Base Image: ["$select_base_image"]"
echo "Tag: ["$tag"]"
echo "Proxy: ["$use_proxy"]"

docker build . \
    --build-arg BASE_IMAGE=${select_base_image} \
    --build-arg USE_APT_PROXY=${use_proxy} \
    -t giof71/librespot:$tag

