# librespot-docker

A Docker image for librespot

## Reference

First and foremost, the reference to the awesome project:

[Librespot](https://github.com/librespot-org/librespot)

I am also currently relying on Raspotify because building images from crates.io fails for armhf platfrom. So here is the reference to this other excellent project:

[Raspotify](https://github.com/dtcooper/raspotify)

## Links

Source: [GitHub](https://github.com/giof71/librespot-docker)  
Images: [DockerHub](https://hub.docker.com/r/giof71/librespot)

## Why

I prepared this Dockerfile Because I wanted to be able to install librespot easily on any machine (provided the architecture is amd64, armhf or arm64). Also I wanted to be able to configure and govern the parameter easily, maybe through a webapp like Portainer.

## Prerequisites

First, you need a [Spotify](https://www.spotify.com) premium account in order to be able to use any version of Librespot.  
You need to have Docker up and running on a Linux machine, and the current user must be allowed to run containers (this usually means that the current user belongs to the "docker" group).  

You can verify whether your user belongs to the "docker" group with the following command:

`getent group | grep docker`

This command will output one line if the current user does belong to the "docker" group, otherwise there will be no output.

The Dockerfile and the included scripts have been tested on the following distros:

- Manjaro Linux with Gnome (amd64)
- Raspberry Pi 3/4 (32 and 64 bit)
- Asus Tinkerboard with DietPi ([don't let that board run at a very low minimum frequency](https://github.com/GioF71/squeezelite-docker/blob/main/doc/asus-tinkerboard.md))
- OSMC on Raspberry Pi 4

As I test the Dockerfile on more platforms, I will update this list.

## Get the image

Here is the [repository](https://hub.docker.com/repository/docker/giof71/librespot) on DockerHub.

Getting the image from DockerHub is as simple as typing:

`docker pull giof71/librespot:latest`

## Librespot is gapless

Mr. [John Darko](https://darko.audio/) would be proud.

## Configuration

### Environment variables

The following tables reports all the currently supported environment variables.

VARIABLE|DEFAULT|NOTES
:---|:---|:---
SPOTIFY_USERNAME||Your Spotify username. Required only if you want to disable discovery.
SPOTIFY_PASSWORD||Your Spotify password. Required only if you want to disable discovery.
BITRATE|160|Bitrate (kbps): `96`, `160`, `320`. Defaults to `160`.
BACKEND|alsa|Audio backend to use. Use `?` to list options. Currently possible values are `alsa` and `pulseaudio`.
INITIAL_VOLUME||Initial volume in % from 0-100. Default for softvol: `50`. For the `alsa` mixer: the current volume.
DEVICE_NAME||Device name (spaces allowed).
DEVICE_TYPE|speaker|Displayed device type: `computer`, `tablet`, `smartphone`, `speaker`, `tv`, `avr` (Audio/Video Receiver), `stb` (Set-Top Box), `audiodongle`, `gameconsole`, `castaudio`, `castvideo`, `automobile`, `smartwatch`, `chromebook`, `carthing`, `homething`. Defaults to `speaker`.
DEVICE||Audio device to use. Use `?` to list options if using `alsa`, `portaudio` or `rodio`. Enter the path to the output when using `pipe`. Defaults to the backend's default.
FORMAT|S16|Output format: `F64`, `F32`, `S32`, `S24`, `S24_3`, `S16`. Defaults to `S16`.
ENABLE_CACHE||`Y` or `y` to enable, uses corresponding volume.
ENABLE_SYSTEM_CACHE||`Y` or `y` to enable (recommended), uses corresponding volume (also recommeneded to use).
CACHE_SIZE_LIMIT||Limits the size of the cache for audio files. It's possible to use suffixes like `K`, `M` or `G`.
DISABLE_AUDIO_CACHE||`Y` or `y` to disable.
DISABLE_CREDENTIAL_CACHE||`Y` or `y` to disable.
MIXER|softvol|Mixer to use: `softvol`, `alsa`. Defaults to `softvol`.
ALSA_MIXER_CONTROL|PCM|`alsa` mixer control, e.g. `PCM`, `Master` or similar. Defaults to `PCM`.
ALSA_MIXER_DEVICE||`alsa` mixer device, e.g `hw:0` or similar from `aplay -l`. Defaults to `--device` if specified, `default` otherwise.
ALSA_MIXER_INDEX|0|`alsa` mixer index, Index of the cards mixer. Defaults to `0`.
QUIET||Only log warning and error messages. `Y` or `y` to enable
VERBOSE||Enable verbose output. `Y` or `y` to enable.
PROXY||Use a proxy for HTTP requests. Proxy should be an HTTP proxy in the form `http://ip:port`, and can also be passed using the all-lowercase http_proxy environment variable.
AP_PORT||Connect to an AP with a specified port. If no AP with that port is present a fallback AP will be used. Available ports are usually `80`, `443` and `4070`.
DISABLE_DISCOVERY||Disable zeroconf discovery mode. `Y` or `y` to disable discovery.
DITHER||Dither algorithm: none, gpdf, tpdf, tpdf_hp. Defaults to tpdf for formats S16, S24, S24_3 and none for other formats.
ZEROCONF_PORT||The port the internal server advertises over zeroconf: `1` - `65535`. Ports <= `1024` may require root privileges.
ENABLE_VOLUME_NORMALISATION||Enables volume normalisation for librespot. `Y` or `y` to enable.
NORMALISATION_METHOD||Specify the normalisation method to use: `basic`, `dynamic`. Defaults to `dynamic`.
NORMALISATION_GAIN_TYPE||Specify the normalisation gain type to use: `track`, `album`, `auto`. Defaults to `auto`.
NORMALISATION_PREGAIN||Pregain (dB) applied by the normalisation. Defaults to `0`.
NORMALISATION_THRESHOLD||Threshold (dBFS) to prevent clipping. Defaults to `-2.0`.
NORMALISATION_ATTACK||Attack time (ms) in which the dynamic limiter is reducing gain. Defaults to `5`.
NORMALISATION_RELEASE||Release or decay time (ms) in which the dynamic limiter is restoring gain. Defaults to `100`.
NORMALISATION_KNEE||Knee steepness of the dynamic limiter. Default is `1.0`.
VOLUME_CTRL||Volume control type `cubic`, `fixed`, `linear`, `log`. Defaults to `log`.
VOLUME_RANGE||Range of the volume control (dB). Default for softvol: `60`. For the `alsa` mixer: what the control supports.
AUTOPLAY||Autoplay similar songs when your music ends. `Y` or `y` to enable.
DISABLE_GAPLESS||Disables gapless playback by forcing the sink to close between tracks. `Y` or `y` to disable gapless mode.
PASSTHROUGH||Pass a raw stream to the output. Only works with the pipe and subprocess backends. `Y` or `y` to enable.
PUID||Set this value the the user which should run the application, defaults to `1000` if not set when using the `pulseaudio` backend
PGID||Set this value the the user which should run the application, defaults to `1000` if not set when using the `pulseaudio` backend
AUDIO_GID||Specifies the gid for the group `audio`, it is required if you want to use, e.g., the `alsa` backend in user mode. Refer to [this page](https://github.com/GioF71/squeezelite-docker/blob/main/doc/example-alsa-user-mode.md) from my squeezelite-docker repository for more details.
PARAMETER_PRIORITY||Where to look for a parameter first: `env` or `file`. For example, the `credentials.txt` file compared to `SPOTIFY_USERNAME` and `SPOTIFY_PASSWORD` environment variables. Defaults to `file`, meaning that each file is considered if it exists and if it contains the required values.
LOG_COMMAND_LINE||Set to  `Y` or `y` to enable, `N` or `n` to disable. Defaults to `Y`.

### Volumes

Volume|Description
:---|:---
/data/cache|Volume for cache, used by --cache (`ENABLE_CACHE`)
/data/system-cache|Volume for system-cache (recommended), used by --system-cache (`ENABLE_SYSTEM_CACHE`).
/user/config|Volume for user-provided configuration. Might contain a `credentials.txt` file.

Please not that the volume `/data/system-cache` will contain the encrypted credentials. Enabling the system cache and using a dedicated volume will help keeping players discoverable by the Spotify web app when you don't provide credentials to LibreSpot.

### Examples

#### Docker-compose

Using docker-compose is preferable for multiple reason, a notable one is the fact that it avoids a few headaches with password escaping, in case of special characters.  

Among the `docker-compose.yaml` files hereby presented, those which use credentials require a `.env` file at the same level of the `docker-compose.yaml` file itself. The `.env` file should have the following format:

```text
SPOTIFY_USERNAME=myusername
SPOTIFY_PASSWORD=mypassword
```

##### Docker-compose in Alsa mode

With credentials:

```text
---
version: "3"

services:
  librespot-u12:
    image: giof71/librespot:latest
    container_name: librespot-u12
    devices:
      - /dev/snd:/dev/snd
    environment:
      - DEVICE=hw:x20,0
      - SPOTIFY_USERNAME=${SPOTIFY_USERNAME}
      - SPOTIFY_PASSWORD=${SPOTIFY_PASSWORD}
      - BACKEND=alsa
      - BITRATE=320
      - INITIAL_VOLUME=100
      - DEVICE_NAME=gustard-u12
```

Discovery mode:

```text
---
version: "3"

services:
  librespot-u12:
    image: giof71/librespot:latest
    container_name: librespot-u12
    network_mode: host
    devices:
      - /dev/snd:/dev/snd
    environment:
      - DEVICE=hw:x20,0
      - BACKEND=alsa
      - BITRATE=320
      - INITIAL_VOLUME=100
      - DEVICE_NAME=gustard-u12
```

##### Docker-compose in PulseAudio mode

With credentials:


```text
---
version: "3"

services:
  librespot-pulse:
    image: giof71/librespot:latest
    container_name: librespot-pulse
    environment:
      - SPOTIFY_USERNAME=${SPOTIFY_USERNAME}
      - SPOTIFY_PASSWORD=${SPOTIFY_PASSWORD}
      - BACKEND=pulseaudio
      - BITRATE=320
      - INITIAL_VOLUME=100
      - DEVICE_NAME=manjaro-xeon10-pulse
    volumes:
      - /run/user/1000/pulse:/run/user/1000/pulse
```

Discovery mode:


```text
---
version: "3"

services:
  librespot-pulse:
    image: giof71/librespot:latest
    container_name: librespot-pulse
    network_mode: host
    environment:
      - BACKEND=pulseaudio
      - BITRATE=320
      - INITIAL_VOLUME=100
      - DEVICE_NAME=manjaro-xeon10-pulse
    volumes:
      - /run/user/1000/pulse:/run/user/1000/pulse
```

#### Docker run

##### Docker run in Alsa mode

With credentials:

```text
docker run -d --name librespot \
    --device /dev/snd \
    -e DEVICE_NAME=kodi-living-pi4-tuner \
    -e INITIAL_VOLUME=100 \
    -e BACKEND=alsa \
    -e DEVICE=hw:D10,0 \
    -e FORMAT=S32 \
    -e BITRATE=320 \
    -e INITIAL_VOLUME=100 \
    -e SPOTIFY_USERNAME=myusername \
    -e SPOTIFY_PASSWORD=mypassword \
    --restart unless-stopped \
    giof71/librespot:latest
```

Discovery mode:

```text
docker run -d --name librespot \
    --device /dev/snd \
    --network host \
    -e DEVICE_NAME=kodi-living-pi4-tuner \
    -e INITIAL_VOLUME=100 \
    -e BACKEND=alsa \
    -e DEVICE=hw:D10,0 \
    -e FORMAT=S32 \
    -e BITRATE=320 \
    -e INITIAL_VOLUME=100 \
    --restart unless-stopped \
    giof71/librespot:latest
```

Discovery mode, using docker `--user`:

See [here](https://github.com/GioF71/audio-tools/tree/main/players/librespot/alsa) for a sample configuration using a specified user (uid) in a docker-compose file.  

Please note that with this DAC I had to specify S32 as the format. It would not work with the default (which is S32 for librespot).

##### Docker run in PulseAudio mode

With credentials:

```text
docker run -d
    -e PUID=1000 \
    -e PGID=1000 \
    -e BACKEND=pulseaudio \
    -e BITRATE=320 \
    -e SPOTIFY_USERNAME=myusername \
    -e SPOTIFY_PASSWORD=mypassword \
    -e DEVICE_NAME=librespot-pulse \
    -v /run/user/1000/pulse:/run/user/1000/pulse \
    --name librespot-pulse \
    giof71/librespot:latest
```

Discovery mode:

```text
docker run -d
    -e PUID=1000 \
    -e PGID=1000 \
    --network host \
    -e BACKEND=pulseaudio \
    -e BITRATE=320 \
    -e DEVICE_NAME=librespot-pulse \
    -v /run/user/1000/pulse:/run/user/1000/pulse \
    --name librespot-pulse \
    giof71/librespot:latest
```

### Run as a user-level systemd

When using a desktop system with PulseAudio, running a docker-compose with a `restart=unless-stopped` is likely to cause issues to the entire PulseAudio. At least that is what is systematically happening to me on my desktop systems.  
You might want to create a user-level systemd unit. In order to do that, move to the `pulse` directory of this repo, create a valid `envfile.txt` with your credentials using `envfile-sample.txt` as a template, then run the following to install the service:

```code
./install.sh
```

After that, the service can be controlled using `./start.sh`, `./stop.sh`, `./restart.sh`.  
You can completely uninstall the service by running:

```code
./uninstall.sh`
```

Of course, you might simply want run the Spotify binary client or the web player instead of this service, but this alternative will allow you to control the player on your desktop system from e.g. a smartphone or any Spotify client. And it will consume significantly less resources.  

### Credentials file

Credentials can be stored on a separate file and mounted as `/user/config/credentials.txt`. The format is the same as the standard `.env` file.  
By defaults, `SPOTIFY_USERNAME` and `SPOTIFY_PASSWORD` entries found in this file have the priority against the correspondent environment variables, unless you set the variable `PARAMETER_PRIORITY` to `env`.

## Known issues

### Discovery

For discovery mode to work, you will need to specify `network_mode=host` on the compose file. Otherwise the player will not be discovered.  
In this mode, you will not need to provide username and password, but OTOH any premium spotify user on your network will be able to use your Librespot Player. 
Please note that even in "discovery" mode, the premium account is always required for playback, but it would only not be required to provide the credentials to the container.

### Dependency on Raspotify

I am currently relying, as mentioned before, to the Raspotify project to build this image. Of what Raspotify provides, this container only uses librespot.  
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
2024-03-07|Fix switch for normalisation pregain (see [#81](https://github.com/GioF71/librespot-docker/issues/77))
2023-12-20|Support docker --user mode (see [#77](https://github.com/GioF71/librespot-docker/issues/77))
2023-10-06|Change ownership of volumes (see [#75](https://github.com/GioF71/librespot-docker/issues/75))
2023-09-05|Clean Dockerfile (see [#73](https://github.com/GioF71/librespot-docker/issues/73))
2023-06-23|Pass device name in quotes (see [#67](https://github.com/GioF71/librespot-docker/issues/67))
2023-06-23|Daily builds update `latest` images
2023-06-23|Add support for `bookworm`
2023-05-13|Routine rebuild
2022-10-28|Credentials are not exposed with the command line output
2022-10-28|Enabled reading credentials from file
2022-10-28|Allowed configurability over command line being logged
2022-10-27|Updated github action versions
2022-10-20|Quotes on a few environment variables
2022-10-08|PulseAudio user-level systemd service introduced
2022-10-04|Feature complete (2022-10-04.1)
2022-10-04|Documentation enrichment and cleanup
2022-10-04|Support for cache and system-cache
2022-10-04|Initial Release (2022-10-04)
