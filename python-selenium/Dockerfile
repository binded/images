FROM ubuntu:latest
MAINTAINER Binded (info@binded.com)

RUN su

RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get install -y wget
RUN apt-get install -y python-pip python-dev build-essential
RUN pip install --upgrade pip
RUN apt-get install unzip

RUN apt-get -y purge firefox
RUN apt-get -y install firefox=45.0.2+build1-0ubuntu1
RUN apt-mark hold firefox

RUN apt-get -y install xvfb



ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8