FROM ruby:2.4-alpine3.6
MAINTAINER tgxworld "tgx@discourse.org"

RUN gem install docker-api diffy

ADD generate_filebeat_config /src/bin/generate_filebeat_config

ENTRYPOINT ["/src/bin/generate_filebeat_config"]
