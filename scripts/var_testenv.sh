#!/usr/bin/env bash

set -e

# Setting temporary directory
export TEMP_DIR=${TEMP_DIR:-$(dirname $0)"/tmp"}
## Converting to absolute path if needed
case $TEMP_DIR in
     /*) ;;
     *) TEMP_DIR=$(pwd)/${TEMP_DIR} ;;
esac

if [ ! -d ${TEMP_DIR} ]; then
  mkdir ${TEMP_DIR}
fi

EXPOSE_HOST_PORTS=${EXPOSE_HOST_PORTS:-"false"}

ARCH=$(uname -m)
if [[ "$ARCH" == "arm"* ]]; then
  ARCH=aarch64
else
  ARCH=x86_64
fi
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  DOCKER_URL="https://download.docker.com/linux/static/stable/${ARCH}/docker-20.10.14.tgz"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  DOCKER_URL="https://download.docker.com/mac/static/stable/${ARCH}/docker-20.10.14.tgz"
fi

# Setting required software
## docker
DOCKER_NAME=docker
DOCKER_BIN=$(which ${DOCKER_NAME} || echo none)
if [ "${DOCKER_BIN}" == "none" ] ; then
  export DOCKER_BIN=${TEMP_DIR}/${DOCKER_NAME}
  if [ ! -x "${DOCKER_BIN}" ]; then
    curl -sL ${DOCKER_URL} | tar -xzf - 
    mv docker/docker ${DOCKER_BIN} && rm -rf docker
    chmod 755 ${DOCKER_BIN}
  fi
fi
DOCKER_LIST_NAME=${DOCKER_LIST_NAME:-"docker_ids"}
DOCKER_LIST=${TEMP_DIR}"/"${DOCKER_LIST_NAME}
## curl 
CURL_BIN="${DOCKER_BIN} run -i --rm curlimages/curl"
## jq
JQ_NAME=jq
JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
JQ_BIN=$(which ${JQ_NAME} || echo none)
if [ "${JQ_BIN}" == "none" ] ; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
    export JQ_BIN=${TEMP_DIR}/${JQ_NAME}
    if [ ! -x "${JQ_BIN}" ]; then
      curl -sL ${JQ_URL} -O ${JQ_BIN}
      chmod 755 ${JQ_BIN}
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install jq
    export JQ_BIN=$(which ${JQ_NAME})
  fi
fi
