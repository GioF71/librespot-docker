#!/bin/bash

declare -A base_images

base_images[bullseye]=debian:bullseye-slim
base_images[buster]=debian:buster-slim
base_images[bookworm]=debian:bookworm-slim
base_images[kinetic]=ubuntu:kinetic
base_images[focal]=ubuntu:focal
base_images[jammy]=ubuntu:jammy

DEFAULT_BASE_IMAGE=bullseye
DEFAULT_TAG=latest
DEFAULT_USE_PROXY=N
DEFAULT_BRANCH=master

tag=$DEFAULT_TAG
use_proxy=$DEFAULT_USE_PROXY
use_branch=$DEFAULT_BRANCH

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

if [ -n "${select_branch}" ]; then
  use_branch=${select_branch}
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
echo "Branch: ["$use_branch"]"

docker build . \
    --build-arg BASE_IMAGE=${select_base_image} \
    --build-arg USE_BRANCH=${use_branch} \
    --build-arg USE_APT_PROXY=${use_proxy} \
    -t giof71/librespot:$tag

