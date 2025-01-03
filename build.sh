#!/bin/bash

declare -A rust_images

rust_images[stable]=library/rust:slim
rust_images[bookworm]=library/rust:slim-bookworm
rust_images[bullseye]=library/rust:slim-bullseye

declare -A base_images

base_images[stable]=library/debian:stable-slim
base_images[bookworm]=library/debian:bookworm-slim
base_images[bullseye]=library/debian:bullseye-slim

# DEFAULT_RUST_IMAGE=bookworm
# DEFAULT_TAG=latest
DEFAULT_RUST_IMAGE=library/rust:slim
DEFAULT_BASE_IMAGE=library/debian:stable-slim

DEFAULT_TAG=latest
DEFAULT_USE_PROXY=N
DEFAULT_BRANCH=master

tag=$DEFAULT_TAG
use_proxy=$DEFAULT_USE_PROXY

while getopts r:b:t:p:v: flag
do
    case "${flag}" in
        r) rust_image=${OPTARG};;
        b) base_image=${OPTARG};;
        t) tag=${OPTARG};;
        p) proxy=${OPTARG};;
        v) select_branch=${OPTARG};;
    esac
done

echo "rust_image: $rust_image";
echo "base_image: $base_image";
echo "tag: $tag";
echo "proxy: $proxy";
echo "branch: $select_branch"

if [ -z "${rust_image}" ]; then
  rust_image=$DEFAULT_RUST_IMAGE
fi

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

if [[ -z ${rust_images[$rust_image]} ]]; then
  echo "Image for ["$rust_image"] not found"
  select_rust_image=${rust_images[$DEFAULT_RUST_IMAGE]}
else
  select_rust_image=${rust_images[$rust_image]}
fi

if [[ -z ${base_images[$base_image]} ]]; then
  echo "Image for ["$base_image"] not found"
  select_base_image=${base_images[$DEFAULT_BASE_IMAGE]}
else
  select_base_image=${base_images[$base_image]}
fi

echo "Rust Image: ["$select_rust_image"]"
echo "Base Image: ["$select_base_image"]"
echo "Tag: ["$tag"]"
echo "Proxy: ["$use_proxy"]"

docker buildx build . \
    --build-arg RUST_IMAGE=${select_rust_image} \
    --build-arg BASE_IMAGE=${select_base_image} \
    --build-arg USE_APT_PROXY=${use_proxy} \
    --load \
    -t giof71/librespot:$tag

