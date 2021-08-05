# Multi-architecture Docker builds for Mailpile

<img align="right" style="margin-left:1em" src="https://raw.githubusercontent.com/mailpile/Mailpile/master/shared-data/mailpile-gui/media/logo-color.png" />

![Release](https://github.com/fpiesche/docker-mailpile/actions/workflows/release.yml/badge.svg)
![Nightly](https://github.com/fpiesche/docker-mailpile/actions/workflows/nightly.yml/badge.svg)

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

# Multi-user mode

The alternate `mailpile-multiuser` image will run Mailpile in multiple-user mode. The entrypoint will create users as requested and automatically start the web UI. To run the image and set up three users, `alex`, `bailey` and `chris`:

```console
$ docker run -d \
  -e MAILPILE_USERS="alex bailey chris" \
  -p 8080:80 \
  florianpiesche/mailpile-multiuser
```

Once startup completes, you will be able to use Mailpile at `http://localhost:8080/mailpile/` on your host computer and log in with your chosen user name.

## Configuration

The multi-user image is cofigured using a single environment variable, `MAILPILE_USERS`, which is a space-separated list of users to create in the container and set up as Mailpile users.

## Persistent data

As with the regular image, Mailpile data is stored in an [unnamed docker volume](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume) `/home/`; this volume will hold the data for **all** users.

Also as with the single-user image, a named Docker volume or a mounted host directory can be used for upgrades and backups. You can add this by using the `-v` parameter when running Docker:

```console
$ docker run -d \
  -v mailpile:/home \
  -e MAILPILE_USERS="alex bailey chris" \
  -p 8080:80 \
  florianpiesche/mailpile-multiuser
```

## Security concerns

Note that the data for all users is stored in the same volume. As long as all the users are trusted, there shouldn't be any major security issues arising from this beyond using mailpile in multi-user mode otherwise, as each user's data is fully one-way encrypted with their password and there is no shell login for any of the users.

However, there is of course a risk as if the host machine were compromised and the Docker volume exfiltrated, the intruder would have all your users' data in a single location. Additionally, if a user wanted to take their data away from your server and use it e.g. on their local machine, this is a bit more complex if their data is on a single volume with everyone else's.

You can mitigate this by creating individual volumes for each user's Mailpile data directory only:

```console
$ docker run -d \
  -e MAILPILE_USERS="alex bailey chris" \
  -v mailpile-alex:/home/alex/.local/share/Mailpile \
  -v mailpile-bailey:/home/bailey/.local/share/Mailpile \
  -v mailpile-chris:/home/chris/.local/share/Mailpile \
  -p 8080:80 \
  florianpiesche/mailpile-multiuser
```

## docker-compose in multi-user mode

As adding a separate volume to the Docker command line for every single user starts ballooning your command very quickly, it is *highly* recommended to use `docker-compose` for multi-user mode. As for single-user mode, simply create a file called `docker-compose.yml` in an empty directory on your host machine, paste in the following data, edit it to suit your needs and use `docker-compose up -d` to run the container.

```yaml
version: '2'

volumes:
  mailpile-alex:
  mailpile-bailey:
  mailpile-chris:

services:
  mailpile:
    image: florianpiesche/mailpile-multiuser
    restart: always
    volumes:
      - mailpile-alex:/home/alex/.local/share/Mailpile
      - mailpile-bailey:/home/bailey/.local/share/Mailpile
      - mailpile-chris:/home/alex/.local/share/Mailpile
    ports:
      - 8080:80
    env:
      MAILPILE_USERS: "alex bailey chris"
```
