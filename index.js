

if (process.argv.length < 3)  {
  console.log("usage: node config-filler.js <config file>");
  process.exit(1);
}

var configFile = process.argv[2];

var configJSON = require(configFile);

// RabbitMQ configuration keys
if (typeof(process.env.AMQP_HOST) !== 'undefined') {
  configJSON.rabbitmq.host = process.env.AMQP_HOST;
}
if (typeof(process.env.AMQP_PORT) !== 'undefined') {
  configJSON.rabbitmq.port = parseInt(process.env.AMQP_PORT);
}
if (typeof(process.env.AMQP_USER) !== 'undefined') {
  configJSON.rabbitmq.user = process.env.AMQP_USER;
}
if (typeof(process.env.AMQP_PASSWORD) !== 'undefined') {
  configJSON.rabbitmq.password = process.env.AMQP_PASSWORD;
}
if (typeof(process.env.AMQP_SSL) !== 'undefined' &&
    (process.env.AMQP_SSL == '1' ||
     process.env.AMQP_SSL.toLowerCase() == "true")) {
  configJSON.rabbitmq.ssl = {
                                  "cert_chain_file": "/etc/sensu/ssl/cert.pem",
                                  "private_key_file": "/etc/sensu/ssl/key.pem"
  };
}
if (typeof(process.env.AMQP_VHOST) !== 'undefined') {
  configJSON.rabbitmq.vhost = process.env.AMQP_VHOST;
}

console.log(JSON.stringify(configJSON, null, 2));
