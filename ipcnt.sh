#!/bin/bash

set -e
set -u

declare ifaces="${1:-}" # default to blank to avoid unbound var errors
declare iface=

function human_readable() {
  awk '
    function human(x) {
        s="bkMGTEPYZ";
        while (x>=1000 && length(s)>1)
            {x/=1024; s=substr(s,2)}
        return int(x+0.5) substr(s,1,1)
    }
    {gsub(/^[0-9]+/, human($1)); print}'
}

if [ -z "$ifaces" ] ;then
  ifaces=$(ls /sys/class/net)
fi

for iface in $ifaces ; do
  [ "$iface" == 'lo' ] && continue

  declare rx_bytes=$(cat /sys/class/net/${iface}/statistics/rx_bytes | human_readable)
  declare rx_packets=$(cat /sys/class/net/${iface}/statistics/rx_packets)
  declare rx_errors=$(cat /sys/class/net/${iface}/statistics/rx_errors)
  declare tx_bytes=$(cat /sys/class/net/${iface}/statistics/tx_bytes | human_readable)
  declare tx_packets=$(cat /sys/class/net/${iface}/statistics/tx_packets)
  declare tx_errors=$(cat /sys/class/net/${iface}/statistics/tx_errors)

  echo "Statistics for $iface"
  printf "\tRecieved: %-4s (%s)\tErrors: %s\n" $rx_bytes $rx_packets $rx_errors
  printf "\tTransmit: %-4s (%s)\tErrors: %s\n" $tx_bytes $tx_packets $tx_errors
done

exit 0
