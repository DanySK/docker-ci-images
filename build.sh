#!/bin/bash
set -e
docker build -t $IMAGE_NAME .
docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD
docker push $IMAGE_NAME
