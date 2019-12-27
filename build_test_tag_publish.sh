#!/bin/bash
set -e

readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo.exercises-start-points.XXXXXXXXX)
trap "rm -rf ${TMP_DIR} > /dev/null" INT EXIT
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly IMAGE=cyberdojo/exercises-start-points
readonly SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)
readonly TAG="${SHA:0:7}"

# - - - - - - - - - - - - - - - - - - - - - - - -
build_the_image()
{
  if on_ci; then
    cd "${TMP_DIR}"
    curl_script
    chmod 700 $(script_path)
  fi
  export GIT_COMMIT_SHA="${SHA}"
  $(script_path) start-point create "${IMAGE}" --exercises "${ROOT_DIR}"
  unset GIT_COMMIT_SHA
}

# - - - - - - - - - - - - - - - - - - - - - - - -
curl_script()
{
  local -r raw_github_org=https://raw.githubusercontent.com/cyber-dojo
  local -r repo=commander
  local -r branch=master
  local -r url="${raw_github_org}/${repo}/${branch}/$(script_name)"
  curl -O --silent --fail "${url}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
script_path()
{
  if on_ci; then
    echo "./$(script_name)"
  else
    echo "${ROOT_DIR}/../commander/$(script_name)"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
script_name()
{
  echo cyber-dojo
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_the_image()
{
  docker tag "${IMAGE}:latest" "${IMAGE}:${TAG}"
  echo "${SHA}"
  echo "${TAG}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push "${IMAGE}:latest"
  docker push "${IMAGE}:${TAG}"
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_the_image
tag_the_image
on_ci_publish_tagged_images
