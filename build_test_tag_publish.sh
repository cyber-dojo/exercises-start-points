#!/bin/bash -Ee

readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo.exercises-start-points.XXXXXXXXX)
trap "rm -rf ${TMP_DIR} > /dev/null" INT EXIT
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_the_image()
{
  if on_ci; then
    cd "${TMP_DIR}"
    curl_script
    chmod 700 $(script_path)
  fi
  export GIT_COMMIT_SHA="$(git_commit_sha)"
  $(script_path) start-point create "$(image_name)" --exercises "${ROOT_DIR}"
  unset GIT_COMMIT_SHA
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r expected="${1}"
  local -r actual="${2}"
  if [ "${expected}" != "${actual}" ]; then
    echo ERROR
    echo "expected:'${expected}'"
    echo "  actual:'${actual}'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm "$(image_name)" sh -c 'echo ${SHA}'
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
  local -r sha="$(image_sha)"
  local -r tag="${sha:0:7}"
  docker tag "$(image_name):latest" "$(image_name):${tag}"
  echo "${sha}"
  echo "${tag}"
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
  local -r sha="$(image_sha)"
  local -r tag="${sha:0:7}"
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push "$(image_name):latest"
  docker push "$(image_name):${tag}"
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
export $(versioner_env_vars)
build_the_image
assert_equal "$(git_commit_sha)" "$(image_sha)"
tag_the_image
on_ci_publish_tagged_images
