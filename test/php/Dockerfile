#--------------------------------------
# Image: base
#--------------------------------------
FROM ubuntu:jammy as base

RUN touch /.dummy

ARG APT_HTTP_PROXY
ARG CONTAINERBASE_DEBUG

ENV BASH_ENV=/usr/local/etc/env
SHELL ["/bin/bash" , "-c"]

COPY src/ /

RUN install-containerbase

COPY --chown=1000:0 test/php/test test
WORKDIR /test

#--------------------------------------
# test: php 8.0
#--------------------------------------
FROM base as testa

# no auto env for testing
SHELL [ "/bin/sh", "-c" ]

# renovate: datasource=github-releases packageName=containerbase/php-prebuild
RUN install-tool php 8.3.1


# renovate: datasource=github-releases packageName=composer/composer
RUN install-tool composer 2.6.6

RUN install-tool composer latest

USER 1000

RUN set -ex; \
  [ ! -z "$(command -v php)" ] && echo "php installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("mbstring") ? 0 : 1);') && echo "php-mbstring installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("curl") ? 0 : 1);') && echo "php-curl installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("xml") ? 0 : 1);') && echo "php-xml installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("json") ? 0 : 1);') && echo "php-json installed" || exit 1;

RUN php --version
RUN composer --version

#--------------------------------------
# testd: php 8.0 (non-root)
#--------------------------------------
FROM base as testb

# no auto env for testing
SHELL [ "/bin/sh", "-c" ]

RUN prepare-tool php

USER 1000


# renovate: datasource=github-releases packageName=containerbase/php-prebuild
RUN install-tool php 8.3.1

RUN install-tool composer latest

# renovate: datasource=github-releases packageName=composer/composer
RUN install-tool composer 2.6.6


RUN set -ex; \
  [ ! -z "$(command -v php)" ] && echo "php installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("mbstring") ? 0 : 1);') && echo "php-mbstring installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("curl") ? 0 : 1);') && echo "php-curl installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("xml") ? 0 : 1);') && echo "php-xml installed" || exit 1;

RUN set -ex; \
  $(php -r 'exit(extension_loaded("json") ? 0 : 1);') && echo "php-json installed" || exit 1;

RUN php --version
RUN composer --version

#--------------------------------------
# final
#--------------------------------------
FROM base

COPY --from=testa /.dummy /.dummy
COPY --from=testb /.dummy /.dummy
