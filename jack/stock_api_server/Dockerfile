FROM ruby:2.1.5
MAINTAINER jackchan <jack5241027@gmail.com>

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    vim

RUN mkdir /opt/stock_api_server
WORKDIR /opt/stock_api_server
ADD Gemfile /opt/stock_api_server/Gemfile
ADD Gemfile.lock /opt/stock_api_server/Gemfile.lock
RUN bundle install
ADD . /opt/stock_api_server
