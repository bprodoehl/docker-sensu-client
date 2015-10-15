# Sensu Client Docker Container

### Configuration
Configuration works two ways: provide a config.json file at /etc/sensu/config.json,
or use the following environment variables:

 * AMQP_HOST
 * AMQP_PORT
 * AMQP_USER
 * AMQP_PASSWORD
 * AMQP_VHOST
 * AMQP_SSL - set to true to enable TLS

### Getting Started
```
docker run -d --name sensu-client \
           --hostname sensu-client \
           --env AMQP_HOST="sensu-server.mydomain.com" \
           --env AMQP_PORT=443 \
           --env AMQP_USER=myadminuser \
           --env AMQP_PASSWORD=mysecretpassword \
           --env AMQP_VHOST="/sensu" \
           --env AMQP_SSL=true \
           bprodoehl/sensu-client
```
