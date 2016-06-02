FROM ruby:latest
MAINTAINER atpking (atpking@gmail.com)
EXPOSE 8080 4567
RUN apt-get update && apt-get install -y curl vim redis-server
WORKDIR /code
COPY Gemfile* /code/
RUN ["bundle", "install"]
COPY . /code
CMD ["bash", "./start.sh"]
