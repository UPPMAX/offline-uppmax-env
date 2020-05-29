#!/bin/bash

# build and tag image
docker build -t uppmax/mini-uppmax:0.1 .

# push to dockerhub
docker push uppmax/mini-uppmax:0.1
