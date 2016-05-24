FROM ruby:latest
MAINTAINER atpking (atpking@gmail.com)
EXPOSE 8080
WORKDIR /code
COPY Gemfile* /code/
RUN ["bundle", "install"]
COPY . /code
CMD ["bundle", "exec", "thin", "start", "-C", "thin.yml"]
