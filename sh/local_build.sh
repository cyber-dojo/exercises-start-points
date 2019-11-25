#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly SHA_VALUE=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

SHA="${SHA_VALUE}" \
  ${ROOT_DIR}/../commander/cyber-dojo start-point create \
    cyberdojo/exercises \
      --exercises \
        file://${ROOT_DIR}
