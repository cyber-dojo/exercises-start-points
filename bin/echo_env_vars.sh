#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_env_vars()
{
  docker run --rm cyberdojo/versioner:latest 2> /dev/null
  #
  echo CYBER_DOJO_EXERCISES_START_POINTS_SHA="$(git_commit_sha)"
  echo CYBER_DOJO_EXERCISES_START_POINTS_TAG="$(git_commit_tag)"
  #
  cat $(repo_root)/Basefile.env
}
