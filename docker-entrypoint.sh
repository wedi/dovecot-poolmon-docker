#!/bin/sh
set -e

echo "[$(date)] [INFO] Running entrypoint.sh"
echo "[$(date)] [INFO] Command line arguments: [$@]"

# Ignore environment variables if user is using custom parameters
if [[ ! -z "$@" ]]; then
    echo "[$(date)] [INFO] Startup with command line arguments: /poolmon --foreground $@"
    exec /poolmon --foreground --logfile=/dev/stdout $@
    return $?
fi

options=""

if [[ -n "$DEBUG" ]]; then
    echo "[$(date)] [INFO] Debug: YES"
    options="$options --debug"
fi

if [[ -n "$INTERVAL" ]]; then
    echo "[$(date)] [INFO] Interval: $INTERVAL"
    options="$options --interval=$INTERVAL"
fi

if [[ -n "$TIMEOUT" ]]; then
    echo "[$(date)] [INFO] Timeout: $TIMEOUT"
    options="$options --timeout=$TIMEOUT"
fi

if [[ -n "$PORTS" ]]; then
    echo "[$(date)] [INFO] Ports: $PORTS"
    options="$options $PORTS"
fi

if [[ -n "$ADDITIONAL_OPTIONS" ]]; then
    echo "[$(date)] [INFO] Additional options: $ADDITIONAL_OPTIONS"
    options="$options $ADDITIONAL_OPTIONS"
fi

# Warn if director socket is emtpy
if [ -z "$DIRECTOR_SOCKET" ]; then
    echo "[$(date)] [INFO] Using default director socket."
    DIRECTOR_SOCKET=/var/run/dovecot/director-admin
fi
options="$options --socket=$DIRECTOR_SOCKET"
echo "[$(date)] [INFO] Director socket: $DIRECTOR_SOCKET"

# Wait for director socket to become available
retries=16  # retries=16 => 175 seconds
try=0
while [ ! -S "$DIRECTOR_SOCKET" ]; do
    if [ $try == $retries ]; then
        echo "[$(date)] [FATAL] Director socket is not available. Giving up."
        exit 2
    fi
    # Timeout: sum 2*1.2^k, k=0 to $try.
    sleeptime=`perl -e "printf '%.1f', 2*(1.2**$try)"`
    try=$(($try + 1))
    echo "[$(date)] [WARNING] Director socket is not available. Try $try of $retries. Sleeping ${sleeptime}s ..."
    sleep $sleeptime
done

echo "[$(date)] [INFO] Startup. /poolmon --foreground $options"
exec /poolmon --foreground --logfile=/dev/stdout $options
