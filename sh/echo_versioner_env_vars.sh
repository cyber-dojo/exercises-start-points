#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  #
  echo CYBER_DOJO_EXERCISES_START_POINTS_SHA="$(git_commit_sha)"
  echo CYBER_DOJO_EXERCISES_START_POINTS_TAG="$(git_commit_tag)"
}
