#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"
source "${BIN_DIR}/lib.sh"
source "${BIN_DIR}/echo_env_vars.sh"
export $(echo_env_vars)
readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo.exercises-start-points.XXXXXXXXX)
trap "rm -rf ${TMP_DIR} > /dev/null" INT EXIT

# - - - - - - - - - - - - - - - - - - - - - - - -
build_test_tag()
{
  exit_non_zero_unless_installed docker
  exit_non_zero_unless_installed git
  echo; remove_old_images
  echo; set_git_repo_dir
  echo; build_tagged_image
  echo; show_env_vars
  tag_the_image_to_latest
  assert_base_sha_env_var_inside_image_matches_basefile_env
}

# - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit_non_zero
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - -
installed()
{
  local -r name="${1}"
  if hash "${name}" 2> /dev/null; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - -
stderr()
{
  >&2 echo "ERROR: ${1:-}"
}

# - - - - - - - - - - - - - - - - - - - - - - -
set_git_repo_dir()
{
  local -r abs_root_dir="$(repo_root)"
  echo "Checking ${abs_root_dir}"
  echo 'Looking for uncommitted changes'
  if [[ -z $(cd ${abs_root_dir} && git status -s) ]]; then
    echo 'Found none'
    echo "Using ${abs_root_dir}"
    GIT_REPO_DIR="${abs_root_dir}"
  else
    echo 'Found some'
    local -r url="${TMP_DIR}/$(basename ${abs_root_dir})"
    echo "So copying it to ${url}"
    cp -r "${abs_root_dir}" "${TMP_DIR}"
    echo "Committing the changes in ${url}"
    pushd ${url}
    git config user.email 'cyber-dojo-machine-user@cyber-dojo.org'
    git config user.name 'CyberDojoMachineUser'
    git add .
    git commit -m 'Save'
    echo "Using ${url}"
    GIT_REPO_DIR="${url}"
    popd
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  # When doing local development, tagging images from the git commit sha
  # will cause a lot of old images to build up unless they are deleted.
  local -r image_names=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_latest_images "${image_names}" "$(image_name)"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest_images()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image in `echo "${docker_image_ls}" | grep "${name}:"`
  do
    if [ "${image}" != "${name}:latest" ]; then
      if [ "${image}" != "${name}:<none>" ]; then
        docker image rm "${image}"
      fi
    fi
  done
  docker system prune --force
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_tagged_image()
{
  $(cyber_dojo) start-point create "$(image_name):$(git_commit_tag)" --exercises "${GIT_REPO_DIR}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_base_sha_env_var_inside_image_matches_basefile_env()
{
  local -r expected="$(image_base_sha)"
  local -r actual="${CYBER_DOJO_START_POINTS_BASE_SHA}"
  if [ "${expected}" != "${actual}" ]; then
    stderr
    stderr "expected:'${expected}'"
    stderr "  actual:'${actual}'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
cyber_dojo()
{
  local -r name=cyber-dojo
  if [ -x "$(command -v ${name})" ]; then
    >&2 echo "Found executable ${name} on the PATH"
    echo "${name}"
  else
    local -r url="https://raw.githubusercontent.com/cyber-dojo/commander/master/${name}"
    >&2 echo "Did not find executable ${name} on the PATH"
    >&2 echo "Curling it to /tmp from ${url}"
    curl --fail --output "${TMP_DIR}/${name}" --silent "${url}"
    chmod 700 "${TMP_DIR}/${name}"
    echo "${TMP_DIR}/${name}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_the_image_to_latest()
{
  # remove_all_but_latest_images relies on :latest existing
  # so as not to bust all the docker layer caching
  docker tag "$(image_name):$(git_commit_tag)" "$(image_name):latest"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
show_env_vars()
{
  # If you doing local development, your echo_versioner_env_vars() function
  # (in dependent repos), will need to add these overrides.
  echo "  echo CYBER_DOJO_EXERCISES_START_POINTS_SHA=$(git_commit_sha)"
  echo "  echo CYBER_DOJO_EXERCISES_START_POINTS_TAG=$(git_commit_tag)"
}

exit_non_zero_unless_installed docker git
build_test_tag
