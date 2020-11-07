#!/bin/bash
set -e
docker build -t $IMAGE_NAME .
echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin
docker push $IMAGE_NAME
