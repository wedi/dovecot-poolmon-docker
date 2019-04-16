FROM alpine:latest

LABEL description="poolmon: health checks for dovecot director backend nodes"
LABEL maintainer="Dirk Weise, code@dirk-weise.de"
LABEL url="https://github.com/wedi/dovecot-poolmon-docker"

ARG POOLMON_VERSION=0.6

ENV ADDITIONAL_OPTIONS ""
ENV DEBUG ""
ENV DIRECTOR_SOCKET /var/run/dovecot/director-admin
ENV INTERVAL "30"
ENV PORTS "--port=110 --port=143 --ssl=993 --ssl=995 --port=24"
ENV TIMEOUT "10"

RUN apk add --no-cache --update perl perl-io-socket-inet6 perl-io-socket-ssl && \
    wget https://raw.githubusercontent.com/brandond/poolmon/$POOLMON_VERSION/poolmon -O /poolmon  && \
    chmod u+x /poolmon

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
