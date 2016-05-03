FROM ruby:2.2.0
MAINTAINER atpking (atpking@gmail.com)
COPY . /code
WORKDIR /code
RUN "bundle install"
CMD "bundle exec thin start -C thin.yml"
