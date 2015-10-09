#!/bin/sh

cd /root/sensu_certs/
./ssl_certs.sh clean
./ssl_certs.sh generate

mkdir -p /etc/sensu/ssl
cp server_key.pem /etc/sensu/ssl/
cp server_cert.pem /etc/sensu/ssl/
cp testca/cacert.pem /etc/sensu/ssl/
