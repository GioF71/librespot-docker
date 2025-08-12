# librespot-docker

A Docker image for [librespot](https://github.com/librespot-org/librespot)

## News

The upcoming `latest` image, based on the current `dev` branch of [librespot](https://github.com/librespot-org/librespot), at [this commit](https://github.com/librespot-org/librespot/commit/ba3d501b08345aadf207d09b3a0713853228ba64), is currently building (see [here](https://github.com/GioF71/librespot-docker/actions/runs/16904408175)).  
For now, I am using [my fork of librespot](https://github.com/GioF71/librespot), purposedly created just to have a tag named `dev-2025-08-11` at the specified commit.  
As this updated `latest` image is expected to be publicly available at around `14:30:00 CEST 12 August 2025`, in the meantime you can use the already available image tagged as `develop-2025-08-11-bookworm`, see [on DockerHub](https://hub.docker.com/r/giof71/librespot/tags?name=develop-2025-08-11).  
These images fix [this issue](https://github.com/GioF71/librespot-docker/issues/128), without the need to apply the suggested workaround (for that, thanks to [this post on Moode Audio forum](https://moodeaudio.org/forum/showthread.php?tid=7915&pid=65727#pid65727)).  

## Reference

First and foremost, the reference to the awesome project:

[Librespot](https://github.com/librespot-org/librespot)

For a long time, I have also been relying on Raspotify because I could not build images using cargo build for the armhf platfrom. So here is the reference to this other excellent project:

[Raspotify](https://github.com/dtcooper/raspotify)

Since the first days of 2025, we are successfully building the images directly from source code.

## Support

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/H2H7UIN5D)  
Please see the [Goal](https://ko-fi.com/giof71/goal?g=0).  
Please note that support goal is limited to cover running costs for subscriptions to music services.

## Links

REPOSITORY TYPE|LINK
:---|:---
Git Repository|[GitHub](https://github.com/giof71/librespot-docker)  
Docker Images|[DockerHub](https://hub.docker.com/r/giof71/librespot)

## Why

I prepared this Dockerfile Because I wanted to be able to install librespot easily on any machine (provided the architecture is amd64, armhf or arm64). Also I wanted to be able to configure and govern the parameter easily, maybe through a webapp like Portainer.

## Prerequisites

First, you need a [Spotify](https://www.spotify.com) premium account in order to be able to use any version of Librespot.  
You need to have Docker up and running on a Linux machine, and the current user must be allowed to run containers (this usually means that the current user belongs to the "docker" group).  

You can verify whether your user belongs to the "docker" group with the following command:

`getent group | grep docker`

This command will output one line if the current user does belong to the "docker" group, otherwise there will be no output.

The Dockerfile and the included scripts have been tested on the following distros:

- Manjaro Linux with Gnome/KDE (amd64)
- Raspberry Pi 3/4 (32 and 64 bit)
- Asus Tinkerboard with DietPi ([don't let that board run at a very low minimum frequency](https://github.com/GioF71/squeezelite-docker/blob/main/doc/asus-tinkerboard.md))
- OSMC on Raspberry Pi 4
- Moode Audio on Raspberry Pi 3/4

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
SPOTIFY_USERNAME||Your Spotify username. Required only if you want to disable discovery (DEPRECATED).
SPOTIFY_PASSWORD||Your Spotify password. Required only if you want to disable discovery (DEPRECATED).
BITRATE|160|Bitrate (kbps): `96`, `160`, `320`. Defaults to `160`.
BACKEND|alsa|Audio backend to use. Use `?` to list options. Currently possible values are `alsa`, `pulseaudio` and `pipe`.
INITIAL_VOLUME||Initial volume in % from 0-100. Default for softvol: `50`. For the `alsa` mixer: the current volume.
DEVICE_NAME||Device name (spaces allowed).
DEVICE_TYPE|speaker|Displayed device type: `computer`, `tablet`, `smartphone`, `speaker`, `tv`, `avr` (Audio/Video Receiver), `stb` (Set-Top Box), `audiodongle`, `gameconsole`, `castaudio`, `castvideo`, `automobile`, `smartwatch`, `chromebook`, `carthing`. Defaults to `speaker`.
DEVICE||Audio device to use. Use `?` to list options if using `alsa`, `portaudio` or `rodio`. Enter the path to the output when using `pipe`. Defaults to the backend's default.
FORMAT|S16|Output format: `F64`, `F32`, `S32`, `S24`, `S24_3`, `S16`. Defaults to `S16`.
ENABLE_CACHE||`Y` or `y` to enable, uses corresponding volume.
ENABLE_SYSTEM_CACHE||`Y` or `y` to enable (recommended), uses corresponding volume (also recommended to use).
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
ZEROCONF_BACKEND||Select the desidered backend, valid values are `avahi`, `libmdns`, `dns-sd`. With the latest builds, I am getting good results with `libmdns`, so it will be the default if discovery is not disabled
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
PASSTHROUGH||Pass a raw stream to the output.  works with the pipe and subprocess backends. `Y` or `y` to enable.
PUID||Set this value the the user which should run the application, defaults to `1000` if not set when using the `pulseaudio` backend
PGID||Set this value the the user which should run the application, defaults to `1000` if not set when using the `pulseaudio` backend
AUDIO_GID||Specifies the gid for the group `audio`, it is required if you want to use, e.g., the `alsa` backend in user mode. Refer to [this page](https://github.com/GioF71/squeezelite-docker/blob/main/doc/example-alsa-user-mode.md) from my squeezelite-docker repository for more details.
PARAMETER_PRIORITY||Where to look for a parameter first: `env` or `file`. For example, the `credentials.txt` file compared to `SPOTIFY_USERNAME` and `SPOTIFY_PASSWORD` environment variables. Defaults to `file`, meaning that each file is considered if it exists and if it contains the required values.
ONEVENT_COMMAND||Specifies the name of a user defined script/executable that will be executed whenever a player event occurs. User defined scripts must be mounted to the `/userscripts/` folder and be made executable via `chmod u+x`. Internally maps to the `--onevent` flag of `librespot`. More info about usage can be found in [librespot's player event handler](https://github.com/librespot-org/librespot/blob/dev/src/player_event_handler.rs).
ONEVENT_POST_ENDPOINT||Send a `POST` request with event data to the specified endpoint URL whenever a player event occurs. Request body is `json` encoded and contains all available fields specified by the [librespot's player event handler](https://github.com/librespot-org/librespot/blob/dev/src/player_event_handler.rs). Will be ignored if `ONEVENT_COMMAND` is set.
ENABLE_OAUTH||Set to `headless` to enable OAUTH authentication. You will need to run the container interactively the first time. Recommended to enable when caching is also enabled, otherwise the credentials file will be lost when the container is recreated.
LOG_COMMAND_LINE||Set to  `Y` or `y` to enable, `N` or `n` to disable. Defaults to `Y`.
ADDITIONAL_ARGUMENTS||Use this to add additional arguments to be appended to the command line

### Pipe Mode

When using BACKEND=pipe, specify a device (using variable DEVICE) that is mounted to a fifo file. Example:

```text
services:
  librespot:
    image: giof71/librespot:latest
    network_mode: host
    environment:
      - BACKEND=pipe
      - DEVICE=/mnt/pipe/spotipipe
      - BITRATE=320
      - INITIAL_VOLUME=100
      - DEVICE_NAME=SpotiPi
    volumes:
      - /path/to/folder/for/fifo-file:/mnt/pipe
```

Thank you @marco79cgn for your contributions on [issue #111](https://github.com/GioF71/librespot-docker/issues/111).  

### Volumes

Volume|Description
:---|:---
/data/cache|Volume for cache, used by --cache (`ENABLE_CACHE`)
/data/system-cache|Volume for system-cache (recommended), used by --system-cache (`ENABLE_SYSTEM_CACHE`).
/user/config|Volume for user-provided configuration. Might contain a `credentials.txt` file.

Note that the volume `/data/system-cache` will contain the encrypted credentials. Enabling the system cache and using a dedicated volume will help keeping players discoverable by the Spotify web app when you don't provide credentials to LibreSpot.

### Examples

#### Docker-compose

Using docker-compose is preferable for multiple reason, a notable one is the fact that it avoids a few headaches with password escaping, in case of special characters.  

Among the `docker-compose.yaml` files hereby presented, those which use credentials require a `.env` file at the same level of the `docker-compose.yaml` file itself. The `.env` file should have the following format:

```text
SPOTIFY_USERNAME=myusername
SPOTIFY_PASSWORD=mypassword
```

Note that username and password is deprecated as an authentication method in librespot.  

##### Docker-compose in Alsa mode

Discovery mode:

```text
---
version: "3"

services:
  librespot:
    image: giof71/librespot:latest
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

Discovery mode:

```text
---
version: "3"

services:
  librespot:
    image: giof71/librespot:latest
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

Note that with this DAC I had to specify S32 as the format. It would not work with the default (which is S32 for librespot).

##### Docker run in PulseAudio mode

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

### Running interactively

If you have set ENABLE_OAUTH to `headless`, you will need to run your docker-compose.yaml interactively the first time.  
In order to do that, run your compose file using the following:

```text
docker-compose run librespot
```

assuming that `librespot` is the name of the service. Tune the command if needed.  
This command will let you see the container logs. You will have to open your browser at the displayed link, authenticated with Spotify and authorize the device, then paste the redirect URL to the terminal.  
After the first start, you can start the container as usual using `docker-compose up -d`.

### Credentials file (DEPRECATED)

Credentials can be stored on a separate file and mounted as `/user/config/credentials.txt`. The format is the same as the standard `.env` file.  
By defaults, `SPOTIFY_USERNAME` and `SPOTIFY_PASSWORD` entries found in this file have the priority against the correspondent environment variables, unless you set the variable `PARAMETER_PRIORITY` to `env`.

## Known issues

### Discovery

For discovery mode to work, you will need to specify `network_mode=host` on the compose file. Otherwise the player will not be discoverable.  
In this mode, authentication is not required on the container itself, but OTOH any premium spotify user on your network will be able to use your Librespot Player.  
Note that even when using the "discovery" mode, the premium account is always required for playback.  

## Build

You can build (or rebuild) the image by opening a terminal from the root of the repository and issuing the following command:

`docker build . -t giof71/librespot`

Now that we are building from code, please note that the build will take quite a lot of time. When it's finished, you can run the container following the previous instructions.  
Just be careful to use the tag you have built.

## Change History

Change Date|Major Changes
---|---
2025-08-12|Build using current `dev` branch at [this commit](https://github.com/librespot-org/librespot/commit/ba3d501b08345aadf207d09b3a0713853228ba64), using my fork
2025-03-27|Fix autoplay (see [#122](https://github.com/GioF71/librespot-docker/issues/122))
2025-01-27|Build latest tag v0.6.0 instead of default branch
2025-01-26|Added curl to the runtime dependencies (see [#113](https://github.com/GioF71/librespot-docker/issues/113))
2025-01-03|Restored arm/v7 build
2025-01-03|Build using cargo (see [#103](https://github.com/GioF71/librespot-docker/issues/103))
2024-12-29|First release including [Raspotify 0.4.6](https://github.com/dtcooper/raspotify/releases/tag/0.46.0) (see [#101](https://github.com/GioF71/librespot-docker/issues/101))
2024-11-22|Add support for OAUTH authentication (see [#96](https://github.com/GioF71/librespot-docker/issues/96))
2024-11-17|Fix docker warning (see [#94](https://github.com/GioF71/librespot-docker/issues/94))
2024-11-16|Add support for `-onevent` (see [#91](https://github.com/GioF71/librespot-docker/issues/91)), thanks to [@QuadratClown](https://github.com/QuadratClown)
2024-09-21|Use exec instead of eval
2024-09-05|Handle non-writable volumes more gracefully
2024-09-05|Fix user and group management
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
