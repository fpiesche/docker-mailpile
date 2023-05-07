FROM debian:buster-slim AS base

ARG GID=1000
ARG UID=1000
ARG MAILPILE_VERSION=nightly
ARG DEBIAN_FRONTEND=noninteractive

ENV MAILPILE_GNUPG_AGENT="/usr/bin/gpg-agent" \
    MAILPILE_GNUPG_DIRMNGR="/usr/bin/dirmngr" \
    MAILPILE_TOR="/usr/sbin/tor" \
    MAILPILE_OPENSSL="/usr/bin/openssl" \
    MAILPILE_GNUPG="/usr/bin/gpg1" \
    MAILPILE_VERSION=${MAILPILE_VERSION}

RUN apt-get update && \
    # Install basic requirements
    apt-get install -y --no-install-recommends curl wget apt-transport-https gnupg1 ca-certificates && \
    # Add mailpile repo
    mkdir -p /etc/apt/keyrings/ && \
    wget -O- https://packages.mailpile.is/deb/key.asc | gpg1 --dearmor | tee /etc/apt/keyrings/mailpile.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/mailpile.gpg] https://packages.mailpile.is/deb ${MAILPILE_VERSION} main" | tee /etc/apt/sources.list.d/000-mailpile.list && \
    # Install mailpile
    apt-get update && apt-get install -y mailpile && \
    # Start tor
    update-rc.d tor defaults && \
    # Tidy up apt
    apt-get clean

#
#  regular target: Single-user Mailpile image
#

FROM base as mailpile

# Create mailpile user and set up
RUN groupadd -g $GID mailpile && useradd -u $UID -g $GID -m mailpile && \
    su - mailpile -c 'mailpile setup'

# Expose port and set up a volume for data persistence
EXPOSE 33411
VOLUME /home/mailpile/.local/share/Mailpile

# Run mailpile
USER mailpile
WORKDIR /home/mailpile
CMD mailpile --www=0.0.0.0:33411 --wait

#
#  alternate target: multi-user Mailpile image
#

FROM base AS mailpile-multiuser

RUN groupadd -g $GID mailpile && \
    apt-get update && apt-get install -y mailpile mailpile-apache2 && \
    apt-get clean

# Expose port, copy entrypoint and set up a volume for data persistence
ENV MAILPILE_USERS="mailpile"
EXPOSE 80
COPY multipile-files/multipile-entrypoint.sh /usr/share/mailpile/multipile/multipile-entrypoint.sh
COPY multipile-files/multipile.rc /etc/mailpile/multipile.rc
VOLUME /home/

# Run mailpile entrypoint
CMD [ "/bin/bash", "/usr/share/mailpile/multipile/multipile-entrypoint.sh" ]
