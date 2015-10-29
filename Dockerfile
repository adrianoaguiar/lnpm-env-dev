FROM ubuntu:14.04
RUN mkdir -p /var/www \
    && apt-get update \                                                                                                                                                   130
    && apt-get -q -y install git \
    && git clone https://github.com/SergeyCherepanov/lnpm-env-dev.git /tmp/lnpm-env-dev \
    && bash /tmp/lnpm-env-dev/install-1404.sh
    && rm -rf /tmp/lnpm-env-dev
VOLUME ["/var/www"]
