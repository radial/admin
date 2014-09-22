#!/bin/bash
set -e

export SPOKES=""

# Wait until the Hub container is done loading all configuration.
echo "Waiting for Hub container to load..."
while [ -d /run/hub.lock ]; do
    sleep 1s
done
echo "...done"

echo "Extracting wheel information..."
cd /run/supervisor
shopt -s nullglob
cID=(*/)
shopt -u nullglob

for d in "${cID[@]}"; do
    app=$(find /run/supervisor/$d -type f -not -name "supervisor*" | awk -F '/' '{print $5}')
    SPOKES="$SPOKES $app"
    export $(echo "$app=${d:: -1}")
    export $(echo "${app}_sock=unix:///run/supervisor/${d}/supervisor.sock")
done
echo "...done"

if [ ! -e /tmp/first_run ]; then
    touch /tmp/first_run

    if [ ! $GH_USER = "/__NULL__/" ]; then
        # Import public keys from github
        ssh-import-id --output /root/.ssh/authorized_keys gh:$GH_USER
        # Start ssh daemon
        /bin/sh -c "while [ ! -e /var/local/run/supervisord.pid ]; do sleep 1s; done &&
                    supervisorctl -s unix:///var/local/run/supervisor.sock start sshd" &
    fi
fi

if [ $# -eq 0 ]; then
    exec supervisord \
        --nodaemon \
        --configuration=/etc/supervisor/supervisord.conf
else
    supervisord \
        --configuration=/etc/supervisor/supervisord.conf
    /bin/bash -c "$@"
fi
