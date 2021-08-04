#!/bin/bash

function log () {
    echo "[$(date +%F_%T)] $1"
}

function quit () {
    if [ -z $2 ]; then
        $exitcode=0
    else
        $exitcode=$2
    fi

    $message=$1

    log $message
    exit $exitcode
}

if [ ! -f /var/lib/mailpile/apache/usermap.txt ]; then
    touch /var/lib/mailpile/apache/usermap.txt
fi

if [ ! -z "$MAILPILE_USERS" ]; then
    for username in $MAILPILE_USERS; do
        if [ -d /home/${username}/.local/share/Mailpile ]; then
            log "User $username already set up for Mailpile."
        else
            log "Adding user $username..."
            useradd -g mailpile -m $username
            log "Setting up Mailpile for $username..."
            /usr/share/mailpile/multipile/mailpile-admin.py --user $username --start
        fi
    done
fi

# /usr/share/mailpile/multipile/mailpile-admin.py --configure-apache
log "Multipile set up! Please refer to https://github.com/mailpile/Mailpile/tree/master/shared-data/multipile for documentation on Multipile."
apachectl restart
tail -f /var/log/apache2/error.log
