#!/bin/sh
MSYS_NO_PATHCONV=1

# nikto only output json result

# example: ./nikto-scan-json.sh "http://host.docker.internal:8089"
# example: ./nikto-scan-json.sh "http://host.docker.internal:8089" 20m


# Check is Lock File exists, if not create it and set trap on exit
LOCKFILE=/tmp/nikto-scan.lock
if { set -C; 2>/dev/null > $LOCKFILE; }; then
    trap "rm -f $LOCKFILE" EXIT
else
    echo "Device or resource busy! exiting"
    exit 16; # Device or resource busy
fi


URL=$1
OUTPUT_FILE=$(mktemp)
MAXTIME=${3:-20m}

nikto -maxtime $MAXTIME -Tuning b -Cgidirs none -o "$OUTPUT_FILE" -Format json -h "$URL" > /dev/null 2>&1

# echo $OUTPUT_FILE
cat $OUTPUT_FILE