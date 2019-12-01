#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

readonly GITHUB_ORG=https://raw.githubusercontent.com/cyber-dojo
readonly REPO_NAME=commander
readonly BRANCH_NAME=master
readonly SCRIPT_NAME=cyber-dojo
readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo-exercises.XXXXXXXXX)

remove_tmp_dir() { rm -rf ${TMP_DIR} > /dev/null; }
trap remove_tmp_dir EXIT

cd ${TMP_DIR}
curl -O --silent --fail "${GITHUB_ORG}/${REPO_NAME}/${BRANCH_NAME}/${SCRIPT_NAME}"
chmod 700 ./${SCRIPT_NAME}

export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)
export CYBER_DOJO_EXERCISES_PORT=4525

readonly IMAGE_NAME=cyberdojo/exercises-start-points:latest

./${SCRIPT_NAME} start-point create \
  ${IMAGE_NAME} \
    --exercises \
      https://github.com/cyber-dojo/exercises-start-points.git
