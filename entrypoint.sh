#!/usr/bin/env sh
set -e

CARBON_DEST1="${DEST1:-unknown}"
CARBON_DEST2="${DEST2:-unknown}"

if [ "$CARBON_DEST1" = "unknown" ]; then
       sed -i '/CARBON_DEST1/ d' /etc/carbon-relay-ng/carbon-relay-ng.ini
fi
if [ "$CARBON_DEST2" = "unknown" ]; then
       sed -i '/CARBON_DEST2/ d' /etc/carbon-relay-ng/carbon-relay-ng.ini
fi

sed -i "s/CARBON_DEST1/$CARBON_DEST1/;s/CARBON_DEST2/$CARBON_DEST2/" /etc/carbon-relay-ng/carbon-relay-ng.ini

su-exec carbon /usr/bin/carbon-relay-ng /etc/carbon-relay-ng/carbon-relay-ng.ini
