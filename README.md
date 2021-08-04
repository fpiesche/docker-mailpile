# Multi-architecture Docker builds for Mailpile

<img align="left" style="margin-right:1em" src="https://raw.githubusercontent.com/mailpile/Mailpile/master/shared-data/mailpile-gui/media/logo-color.png" />

![Release (single-user)](https://github.com/fpiesche/docker-mailpile/actions/workflows/build-tags.yml/badge.svg)
![Release (multi-user)](https://github.com/fpiesche/docker-mailpile/actions/workflows/build-multipile-tags.yml/badge.svg)

![Nightly (single-user)](https://github.com/fpiesche/docker-mailpile/actions/workflows/build-nightly.yml/badge.svg)
![Nightly (multi-user)](https://github.com/fpiesche/docker-mailpile/actions/workflows/build-multipile-nightly.yml/badge.svg)

[Mailpile](https://mailpile.is/) is a self-hosted, modern web email client with good encryption support.

# Quick reference

-   **Image Repositories**:
    - Docker Hub: [`florianpiesche/mailpile`](https://hub.docker.com/r/florianpiesche/mailpile)  
    - GitHub Packages: [`ghcr.io/fpiesche/mailpile`](https://ghcr.io/fpiesche/mailpile)  
    - Docker Hub (multi-user): [`florianpiesche/mailpile-multiuser`](https://hub.docker.com/r/florianpiesche/mailpile-multiuser)  
    - GitHub Packages (multi-user): [`ghcr.io/fpiesche/mailpile-multiuser`](https://ghcr.io/fpiesche/mailpile-multiuser)

-   **Maintained by**:  
	[Florian Piesche](https://github.com/fpiesche) (Docker images)  
    [Mailpile Team](https://github.com/mailpile) (Mailpile application)

-	**Where to file issues**:  
    [https://github.com/fpiesche/docker-mailpile/issues](https://github.com/fpiesche/docker-mailpile/issues) (Docker images)  
    [https://github.com/mailpile/Mailpile/issues](https://github.com/mailpile/Mailpile/issues) (Mailpile application)

-   **Base image**:
    [debian:buster-slim](https://hub.docker.com/_/debian/)

-   **Dockerfile**:
    [https://github.com/fpiesche/docker-mailpile/blob/main/Dockerfile](https://github.com/fpiesche/docker-mailpile/blob/main/Dockerfile)

-	**Supported architectures**:
    Each image is a multi-arch manifest for the following architectures:
    `amd64`, `arm64`, `armv7`, `armv6`

-	**Source of this description**: [Github README](https://github.com/fpiesche/docker-mailpile/tree/master/README.md) ([history](https://github.com/fpiesche/docker-mailpile/commits/master/README.md))

# Supported tags

## Tagged Releases

-   `latest` is based on the most recent tagged [Mailpile release](https://github.com/mailpile/Mailpile/releases).
-   Tag names (e.g. `1.0.0rc6`) are also available for access to specific releases.

## Nightly builds

-   `nightly` is based on the nightly build using the most recent commit to Mailpile's [master branch](https://github.com/mailpile/Mailpile/tree/master/).
-   Individual commits are also available using their individual short commit IDs (e.g. `b5e4b85` for [commit `b5e4b85`](https://github.com/mailpile/Mailpile/commit/b5e4b85))

# How to use this image

This image will run Mailpile in web mode and automatically start the web UI. To run the image:

```console
$ docker run -d -p 8080:80 florianpiesche/mailpile
```

Once startup completes, you will be able to use Mailpile at `http://localhost:8080/` on your host computer.

## Configuration

There is no external configuration needed for this container; all the configuration is done within Mailpile itself and stored in the container's data volume (see below).

## Persistent data

The mailpile data (emails, encryption keys, configuration, etc) are all stored in the [unnamed docker volume](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume) `/home/mailpile/.local/share/Mailpile/`. The docker daemon will store that data within the docker directory `/var/lib/docker/volumes/...`. That means your data is saved even if the container crashes, is stopped or deleted.

A named Docker volume or a mounted host directory can be used for upgrades and backups. You can add this by using the `-v` parameter when running Docker:

	```console
	$ docker run -d \
	-v mailpile:/home/mailpile/.local/share/Mailpile \
    -p 8080:80 \
	florianpiesche/mailpile
	```

## Using docker-compose

The easiest way to get a reproducible setup you can start, stop and resume at will is using a `docker-compose` file. There are too many different possibilities to setup your system, so here are only some examples of what you have to look for.

To use a compose file, create a file called `docker-compose.yaml` in a new, empty directory on your host computer and paste in this data:

```yaml
version: '2'

volumes:
  mailpile:

services:
  mailpile:
    image: florianpiesche/mailpile
    restart: always
    volumes:
      - mailpile:/home/mailpile/.local/share/Mailpile
    ports:
      - 8080:80
```

Then run `docker-compose up -d` in the directory holding the compose file, and you will be able to access Mailpile at http://localhost:8080/ from your host system. You can stop Mailpile at any point using `docker-compose down`, and resume it again with your data stored by re-running `docker-compose up -d`.
