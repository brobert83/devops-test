#!/bin/bash

image=$1
version=$2

docker build -t "${image}:${version}" ./src
docker push "${image}:${version}"
