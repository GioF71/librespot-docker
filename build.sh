#!/bin/bash

declare -A base_images

base_images[alpine-edge]=alpine:edge

DEFAULT_BASE_IMAGE=alpine-edge
DEFAULT_TAG=local
DEFAULT_BRANCH=master

tag=$DEFAULT_TAG
use_proxy=$DEFAULT_USE_PROXY
use_branch=$DEFAULT_BRANCH

while getopts b:t:p:v: flag
do
    case "${flag}" in
        b) base_image=${OPTARG};;
        t) tag=${OPTARG};;
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
echo "Branch: ["$use_branch"]"

docker build . \
    --build-arg BASE_IMAGE=${select_base_image} \
    --build-arg USE_BRANCH=${use_branch} \
    -t giof71/librespot:$tag

