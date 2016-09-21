FROM phusion/baseimage:0.9.18

MAINTAINER Brian Prodoehl <bprodoehl@connectify.me>

ENV HOME /root

### Update the base image
RUN apt-get update && apt-get dist-upgrade -qy
RUN apt-get install -y curl wget make g++

### Install the Sensu Core Repository
RUN wget -q http://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -
RUN echo "deb http://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list

### Prepare for ruby2.3
RUN apt-add-repository ppa:brightbox/ruby-ng

### Install Sensu
RUN apt-get update
RUN apt-get install -y sensu python ruby2.3 ruby2.3-dev

### Configure Sensu
ADD conf/config.json /etc/sensu/config.json.template

### Configure a Check
ADD conf/check_memory.json /etc/sensu/conf.d/check_memory.json
ADD conf/default_handler.json /etc/sensu/conf.d/default_handler.json

### Configure Sensu client
ADD conf/check-memory.sh /etc/sensu/plugins/check-memory.sh
RUN gem install sensu-plugin
RUN sensu-install -p nginx 
RUN sensu-install -p disk-checks 
RUN sensu-install -p network-checks 
RUN sensu-install -p filesystem-checks 
RUN sensu-install -p docker
RUN sensu-install -p graphite:0.0.6

### Add scripts to generate TLS certs
#RUN mkdir /root/sensu_certs
#ADD files/openssl.cnf /root/sensu_certs/openssl.cnf
#ADD files/ssl_certs.sh /root/sensu_certs/ssl_certs.sh

### Install Node.js for config template filling
RUN curl --silent --location https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

RUN mkdir -p /opt/config-filler
ADD index.js /opt/config-filler/

ADD conf/config.json /opt/

### Configure Runit
RUN mkdir /etc/service/sensu-client
ADD runit/sensu-client.sh /etc/service/sensu-client/run
#ADD runit/generate-certs.sh /etc/my_init.d/010-generate-certs.sh

