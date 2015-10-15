#!/bin/sh
set -eu

RUNDIR=/var/run/sensu-client
PIDFILE=$RUNDIR/sensu-client.pid

mkdir -p $RUNDIR
touch $PIDFILE
chown sensu:sensu $RUNDIR $PIDFILE
chmod 755 $RUNDIR

mkdir -p /etc/sensu

if [ ! -e /etc/sensu/config.json ]; then
  echo "Didn't find config.json, copying it over"
  cp -v /opt/config.json /etc/sensu/config.json
fi

node /opt/config-filler/index.js /etc/sensu/config.json > /etc/sensu/config.json.new
if [ ! $? ]; then
  echo "Config filler was happy"
  mv /etc/sensu/config.json.new /etc/sensu/config.js
fi

exec chpst -u sensu /opt/sensu/bin/sensu-client -d /etc/sensu -p $PIDFILE
