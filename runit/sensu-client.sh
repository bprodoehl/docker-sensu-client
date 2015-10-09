#!/bin/sh
set -eu

RUNDIR=/var/run/sensu-client
PIDFILE=$RUNDIR/sensu-client.pid

mkdir -p $RUNDIR
touch $PIDFILE
chown sensu:sensu $RUNDIR $PIDFILE
chmod 755 $RUNDIR

if [ -z ${AMQP_VHOST+x} ]; then AMQP_VHOST=/sensu; else AMQP_VHOST=$AMQP_VHOST; fi
rabbitmqctl add_vhost $AMQP_VHOST
# Create user
if [ -z ${AMQP_USER+x} ]; then AMQP_USER=sensu; else AMQP_USER=$AMQP_USER; fi
if [ -z ${AMQP_PASSWORD+x} ]; then AMQP_PASSWORD=secret; else AMQP_PASSWORD=$AMQP_PASSWORD; fi
rabbitmqctl add_user $AMQP_USER $AMQP_PASSWORD
rabbitmqctl set_permissions -p $AMQP_VHOST $AMQP_USER ".*" ".*" ".*"

if [ -z ${SENSU_API_PORT+x} ]; then SENSU_API_PORT=4567; else SENSU_API_PORT=$SENSU_API_PORT; fi
if [ -z ${SENSU_API_USER+x} ]; then SENSU_API_USER=admin; else SENSU_API_USER=$SENSU_API_USER; fi
if [ -z ${SENSU_API_PASSWORD+x} ]; then SENSU_API_PASSWORD=password; else SENSU_API_PASSWORD=$SENSU_API_PASSWORD; fi
set -e

# use \001 (start-of-header) as the delimiter, as the password can include basically anything
cat /etc/sensu/config.json.template | \
    sed s$'\001''%%AMQP_VHOST%%'$'\001'$AMQP_VHOST$'\001''g' | \
    sed s$'\001''%%AMQP_USER%%'$'\001'$AMQP_USER$'\001''g' | \
    sed s$'\001''%%AMQP_PASSWORD%%'$'\001'$AMQP_PASSWORD$'\001''g' | \
    sed s$'\001''%%SENSU_API_PORT%%'$'\001'$SENSU_API_PORT$'\001''g' | \
    sed s$'\001''%%SENSU_API_USER%%'$'\001'$SENSU_API_USER$'\001''g' | \
    sed s$'\001''%%SENSU_API_PASSWORD%%'$'\001'$SENSU_API_PASSWORD$'\001''g' > /etc/sensu/config.json

exec chpst -u sensu /opt/sensu/bin/sensu-client -d /etc/sensu -p $PIDFILE
