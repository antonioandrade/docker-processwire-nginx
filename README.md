# ProcessWire (Docker Image)

[![Go to Docker Hub](https://img.shields.io/badge/Docker%20Hub-%E2%86%92-blue.svg)](https://hub.docker.com/r/antonioandrade/processwire/)

A Dockerfile that installs the latest nginx, php, php-apc, mysql and Processwire.

Fork from [suzel/docker-processwire](https://github.com/suzel/docker-processwire) The following changes/features were introduced:
* refactored base image to [phusion/baseimage](https://hub.docker.com/r/phusion/baseimage/),
* reduced number of `RUN` calls on Dockerfile and
* (temporarily) uses [**wireshell**](wireshell.pw) to setup new website with default login credentials)`


## Installation

The easiest way to get this docker image installed is to pull the latest version from the Docker registry:

```
$ docker pull antonioandrade/processwire
```

...or build from scratch:

```sh
$ git clone https://github.com/antonioandrade/docker-processwire-nginx.git
$ cd docker-processwire-nginx/
$ docker build -t antonioandrade/processwire .
```

## Usage

Start your image binding external port 80 (web) and 3306 (mysql) to your container:

```sh
$ docker run --name processwire \
             -v $PWD/htdocs:/usr/share/nginx \
             -p 80:80 \
             -p 3306:3306 \
             -d antonioandrade/processwire
```

You can then execute the following to open your new project on your host machine's browser:

```
$ open http://$(docker-machine ip default):8080
```

## Default Credentials
Since we are using **wireshell** to install the new project for us, default admin credentials are the following:
* Username: `admin`
* Password: `password`
* User Email: `email@domain.com`