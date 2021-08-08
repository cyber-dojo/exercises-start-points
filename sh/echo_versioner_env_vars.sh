#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  #
  echo CYBER_DOJO_EXERCISES_START_POINTS_SHA="$(git_commit_sha)"
  echo CYBER_DOJO_EXERCISES_START_POINTS_TAG="$(git_commit_tag)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_tag()
{
  local -r sha="$(git_commit_sha)"
  echo "${sha:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm $(image_name) sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

