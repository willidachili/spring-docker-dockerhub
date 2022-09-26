#!/usr/bin/env bash
# -v (volume) - https://docs.docker.com/storage/volumes/
# --rm cleans up resoruces after we are done
# Golang - name of image on docker hub
# The rest - arguments passed into the container (Run shell commands)
docker run --rm -v $(pwd):/go/workspace golang sh -c "cd workspace;go build -o hello .;./hello"

