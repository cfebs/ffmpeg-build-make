FROM debian:buster
RUN apt-get update && apt-get -y install \
        build-essential \
        curl \
        autoconf \
        cmake \
        libtool \
        vim
RUN mkdir /app
COPY . /app

WORKDIR /app
