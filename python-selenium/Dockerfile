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

RUN apt-get -y install libxss1 libappindicator1 libindicator7
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

RUN apt-get -y install xvfb

RUN apt-get -y install gconf-service libgconf-2-4 libnspr4 libnss3 xdg-utils fonts-liberation

RUN dpkg -i google-chrome*.deb
RUN apt-get install -f


RUN apt-get -y install unzip

RUN wget -N http://chromedriver.storage.googleapis.com/2.26/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN chmod +x chromedriver

RUN mv -f chromedriver /usr/local/share/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/bin/chromedriver


ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
