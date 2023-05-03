#!/bin/sh
MSYS_NO_PATHCONV=1

# example: ./nikto-scan.sh "http://host.docker.internal:8089" out.json
# example: ./nikto-scan.sh "http://host.docker.internal:8089" /tmp/out.json
# example: ./nikto-scan.sh "http://host.docker.internal:8089" "/storage/nikto/output/2/1680667946128_nikto.json" 20m


# Check is Lock File exists, if not create it and set trap on exit
LOCKFILE=/tmp/nikto-scan.lock
if { set -C; 2>/dev/null > $LOCKFILE; }; then
    trap "rm -f $LOCKFILE" EXIT
else
    echo "Device or resource busy! exiting"
    exit 16; # Device or resource busy
fi


URL=$1
OUTPUT_FILE=$(readlink -f "$2")
MAXTIME=${3:-20m}

nikto -maxtime $MAXTIME -Tuning b -Cgidirs none -o "$OUTPUT_FILE" -Format json -h "$URL" || exit 0