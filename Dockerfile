FROM debian:buster-slim AS base
ARG MAILPILE_VERSION=nightly

ENV MAILPILE_GNUPG_AGENT="/usr/bin/gpg-agent" \
    MAILPILE_GNUPG_DIRMNGR="/usr/bin/dirmngr" \
    MAILPILE_TOR="/usr/sbin/tor" \
    MAILPILE_OPENSSL="/usr/bin/openssl" \
    MAILPILE_GNUPG="/usr/bin/gpg1" \
    MAILPILE_VERSION=${MAILPILE_VERSION} \
    DEBIAN_FRONTEND=noninteractive

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
RUN groupadd -g 1000 mailpile && useradd -u 1000 -g 1000 -m mailpile && \
    su - mailpile -c 'mailpile setup'

# Expose port and set up a volume for data persistence
EXPOSE 33411
VOLUME /home/mailpile/.local/share/Mailpile

# Run mailpile
USER mailpile
WORKDIR /home/mailpile
CMD mailpile --www=0.0.0.0:33411 --wait
