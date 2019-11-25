#!/bin/bash
set -e
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
"${ROOT_DIR}/sh/build_docker_images.sh"
