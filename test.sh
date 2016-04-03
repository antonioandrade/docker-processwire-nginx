#!/usr/bin/env bash

eval "$(docker-machine env default)"

docker build -t antonioandrade/processwire .

echo "Stopping container named:"
docker stop processwire
echo "Removing container named:"
docker rm processwire
rm -rf htdocs
mkdir -p htdocs
docker run --name processwire \
             -v $(pwd)/htdocs:/usr/share/nginx \
             -d \
             -p 8080:80 \
             antonioandrade/processwire

echo "Sleeping 90s for start.sh to complete before opening Processwire."
sleep 90s
open http://$(docker-machine ip default):8080