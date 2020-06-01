#!/bin/bash

# build and tag image
docker build -t uppmax/offline-uppmax-env:latest .

# push to dockerhub
docker push uppmax/offline-uppmax-env:latest
