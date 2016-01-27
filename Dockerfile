FROM phusion/baseimage:0.9.17

MAINTAINER Brian Prodoehl <bprodoehl@connectify.me>

ENV HOME /root

### Update the base image
RUN apt-get update && apt-get dist-upgrade -qy
RUN apt-get install -y curl wget

### Install the Sensu Core Repository
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
RUN echo "deb http://repos.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list

### Install Sensu
RUN apt-get update
RUN apt-get install -y sensu python ruby pip

### Configure Sensu
ADD conf/config.json /etc/sensu/config.json.template

### Configure a Check
ADD conf/check_memory.json /etc/sensu/conf.d/check_memory.json
ADD conf/default_handler.json /etc/sensu/conf.d/default_handler.json

### Configure Sensu client
ADD conf/check-memory.sh /etc/sensu/plugins/check-memory.sh

### Add scripts to generate TLS certs
#RUN mkdir /root/sensu_certs
#ADD files/openssl.cnf /root/sensu_certs/openssl.cnf
#ADD files/ssl_certs.sh /root/sensu_certs/ssl_certs.sh

### Install Node.js for config template filling
RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | bash -
RUN apt-get install -y nodejs

RUN mkdir -p /opt/config-filler
ADD index.js /opt/config-filler/

ADD conf/config.json /opt/

### Configure Runit
RUN mkdir /etc/service/sensu-client
ADD runit/sensu-client.sh /etc/service/sensu-client/run
#ADD runit/generate-certs.sh /etc/my_init.d/010-generate-certs.sh
