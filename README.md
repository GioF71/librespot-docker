# librespot-docker - a Docker image for librespot

## Reference

First and foremost, the reference to the awesome project:

[Librespot](https://github.com/librespot-org/librespot)

I am also currently relying on Raspotify because building images from crates.io fails for armhf platfrom. So here is the reference to this other excellent project:

[Raspotify](https://github.com/dtcooper/raspotify)

## Links

Source: [GitHub](https://github.com/giof71/librepot-docker)  
Images: [DockerHub](https://hub.docker.com/r/giof71/librespot)

## Why

I prepared this Dockerfile Because I wanted to be able to install librespot easily on any machine (provided the architecture is amd64 or arm). Also I wanted to be able to configure and govern the parameter easily, maybe through a webapp like Portainer.

## Prerequisites

First, you need a [Spotify](https://www.spotify.com) premium account in order to be able to use any version of Librespot.  
You need to have Docker up and running on a Linux machine, and the current user must be allowed to run containers (this usually means that the current user belongs to the "docker" group).  

You can verify whether your user belongs to the "docker" group with the following command:

`getent group | grep docker`

This command will output one line if the current user does belong to the "docker" group, otherwise there will be no output.

The Dockerfile and the included scripts have been tested on the following distros:

- Manjaro Linux with Gnome (amd64)
- Raspberry Pi 3/4 (32 bit)

As I test the Dockerfile on more platforms, I will update this list.
Notably, I have not yet tested on 64 bit Arm, but this is definitely something I will do shortly.

## Get the image

Here is the [repository](https://hub.docker.com/repository/docker/giof71/librespot) on DockerHub.

Getting the image from DockerHub is as simple as typing:

`docker pull giof71/librespot:latest`

### Environment variables

The following tables reports all the currently supported environment variables.

VARIABLE|DEFAULT|NOTES
---|---|---
SPOTIFY_USERNAME||Your Spotify username
SPOTIFY_PASSWORD||Your Spotify password
BITRATE||Bitrate (kbps): 96, 160, 320. Defaults to 160.
BACKEND||Audio backend to use. Use ? to list options. Define also the device option when using pipe
INITIAL_VOLUME||Initial volume in % from 0-100. Default for softvol: 50. For the alsa mixer: the current volume.
DEVICE_NAME||Device name
DEVICE_TYPE||Displayed device type: computer, tablet, smartphone, speaker, tv, avr (Audio/Video Receiver), stb (Set-Top Box), audiodongle, gameconsole, castaudio, castvideo, automobile, smartwatch, chromebook, carthing, homething. Defaults to speaker.
DEVICE||Audio device to use. Use ? to list options if using alsa, portaudio or rodio. Enter the path to the output when using pipe. Defaults to the backend's default.
FORMAT||Output format: F64, F32, S32, S24, S24_3, S16. Defaults to S16.
PUID||For pulseaudio mode. Set the same as the current user id
PGID||For pulseaudio mode. Set the same as the current group id

### Volumes

Volume|Description
:---|:---

## Known issues

### Discovery

I have not (yet?) been able to run the container without having to specify the credentials, thus relaying in service discovery. This is probably due to docker. I have found a few solution to similar problems, but such solutions seem overly complicated, thus I currently prefer to stick with providing the credentials.  
Please note that even in "discovery" mode, the premium account is always required for playback, but it would only not be required to provide the credentials to the container.

### Dependency on Raspotify

I am currently relying, as mentioned before, to the Raspotify project to build this image. Of what Raspotify, this container only uses librespot.  
I have a branch dedicated to this issue: the problem is with the build on GitHub via QEMU, which fails for the armhf architecture.  
Any help in resolving this issue is welcome. 

## Build

You can build (or rebuild) the image by opening a terminal from the root of the repository and issuing the following command:

`docker build . -t giof71/librespot`

It will take very little time even on a Raspberry Pi. When it's finished, you can run the container following the previous instructions.  
Just be careful to use the tag you have built.

## Change History

Change Date|Major Changes
---|---
