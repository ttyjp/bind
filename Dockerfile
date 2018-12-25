FROM alpine:3.8

ARG OPENSSL_VERSION="1.1.1a"
ARG BIND_VERSION="9.11.5-P1"

RUN apk -U upgrade \
  && apk add --virtual build-dependencies \
        build-base \
        linux-headers \
        perl \
  && cd /tmp \
  && wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
  && tar xzvf openssl-${OPENSSL_VERSION}.tar.gz \
  && cd openssl-${OPENSSL_VERSION} \
  && ./config no-async \
  && make \
  && make install \
  && cd /tmp \
  && wget https://ftp.isc.org/isc/bind9/${BIND_VERSION}/bind-${BIND_VERSION}.tar.gz \
  && tar xzvf bind-${BIND_VERSION}.tar.gz \
  && cd bind-${BIND_VERSION} \
  && ./configure --with-openssl=/usr/local --disable-symtable \
  && make \
  && make install \
  && apk del build-dependencies \
  && apk add libgcc \
  && rm -rf \
        /tmp/* \
        /var/cache/apk/*

RUN addgroup -S -g 101 named \
  && adduser -S -D -H \
        -u 100 \
        -h /var/named \
        -s /sbin/nologin \
        -G named \
        named \
  && mkdir \
        /var/named \
        /var/named/master \
        /var/named/keys \
        /var/named/dsset \
  && chown named.named \
        /var/named \
  && chown root.named \
        /var/named/master \
        /var/named/keys \
        /var/named/dsset \
  && chmod 750 \
        /var/named \
        /var/named/master \
        /var/named/keys \
        /var/named/dsset \
  && rndc-confgen -a -A hmac-sha256 -b 512 \
  && chown root.named /etc/rndc.key \
  && chmod 640 /etc/rndc.key

COPY named.conf /etc/
COPY example.com /var/named/master/

CMD ["/usr/local/sbin/named", "-c", "/etc/named.conf", "-u", "named", "-g", "-4"]