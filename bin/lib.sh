#!/usr/bin/env bash
set -Eeu

git_commit_sha()
{
  git rev-parse HEAD
}

git_commit_tag()
{
  local -r sha="$(git_commit_sha)"
  echo "${sha:0:7}"
}

image_name()
{
  echo "${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}"
}

image_base_sha()
{
  docker run --entrypoint='' --rm "$(image_name):$(git_commit_tag)" \
    sh -c 'echo ${CYBER_DOJO_START_POINTS_BASE_SHA}'
}
