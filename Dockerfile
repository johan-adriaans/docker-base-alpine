FROM alpine:3.4

MAINTAINER Johan Adriaans <johan@shoppagina.nl>

# Add the dumb-init source
ADD dumb-init /usr/src/dumb-init

# Download and build runit and dumb-init
RUN buildDeps='curl tar make gcc musl-dev' \
  RUNIT_VERSION="2.1.2" \
  TZ="Europe/Amsterdam" \
  RUNIT_DOWNLOAD_URL="http://smarden.org/runit/runit-2.1.2.tar.gz" \
  RUNIT_DOWNLOAD_SHA1="398f7bf995acd58797c1d4a7bcd75cc1fc83aa66" \
  && apk add --update bash \
  && set -x \
  && apk add $buildDeps \
  && curl -sSL "$RUNIT_DOWNLOAD_URL" -o runit.tar.gz \
  && echo "$RUNIT_DOWNLOAD_SHA1 *runit.tar.gz" | sha1sum -c - \
  && mkdir -p /usr/src/runit \
  && tar -xzf runit.tar.gz -C /usr/src/runit --strip-components=2 \
  && rm -f runit.tar.gz \
  && cd /usr/src/runit/src \
  && make \
  && cd .. \
  && cat package/commands | xargs -I {} mv -f src/{} /sbin/ \
  && cd / \
  && rm -rf /usr/src/runit \
  && cd /usr/src/dumb-init \
  && make \
  && mv /usr/src/dumb-init/dumb-init /sbin/ \
  && cd / \
  && rm -rf /usr/src/dumb-init \
  && apk del $buildDeps \
  && rm -rf /var/cache/apk/* \
  && mkdir /etc/service \
  && echo $TZ > /etc/TZ

#ADD my_init /
ENTRYPOINT ["/sbin/dumb-init", "/sbin/runsvdir", "-P", "/etc/service"]
