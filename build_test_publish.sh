#!/bin/bash -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SH_DIR="${ROOT_DIR}/sh"
readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo.exercises-start-points.XXXXXXXXX)
trap "rm -rf ${TMP_DIR} > /dev/null" INT EXIT
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)
source "${SH_DIR}/kosli.sh"

# - - - - - - - - - - - - - - - - - - - - - - - -
build_test_publish()
{
  exit_non_zero_unless_installed docker
  exit_non_zero_unless_installed git
  echo; remove_old_images
  echo; set_git_repo_dir
  echo; build_tagged_image
  assert_sha_env_var_inside_image_matches_image_tag
  echo; show_env_vars
  tag_the_image_to_latest
}

# - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed()
{
  local -r name="${1}"
  if ! installed "${name}"; then
    stderr "ERROR: ${name} is not installed"
    exit 42
  fi
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
  >&2 echo "${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - -
set_git_repo_dir()
{
  local -r abs_root_dir="$(cd "${ROOT_DIR}" && pwd)"
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
    cd ${url}
    git config user.email 'cyber-dojo-machine-user@cyber-dojo.org'
    git config user.name 'CyberDojoMachineUser'
    git add .
    git commit -m 'Save'
    echo "Using ${url}"
    GIT_REPO_DIR="${url}"
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
  # GIT_COMMIT_SHA is needed to embed the SHA inside the created image as an env-var
  export GIT_COMMIT_SHA="$(git_commit_sha)"
  $(cyber_dojo) start-point create "$(image_name):$(git_commit_tag)" --exercises "${GIT_REPO_DIR}"
  unset GIT_COMMIT_SHA
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_sha_env_var_inside_image_matches_image_tag()
{
  local -r expected="$(image_sha)"
  local -r actual="$(git_commit_sha)"
  if [ "${expected}" != "${actual}" ]; then
    echo ERROR
    echo "expected:'${expected}'"
    echo "  actual:'${actual}'"
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
  # Creating a versioner release relies on :latest holding the SHA
  # env-var which identifies the 7-character image tag.
  docker tag "$(image_name):$(git_commit_tag)" "$(image_name):latest"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
show_env_vars()
{
  # If you doing local development, your versioner_env_vars() function
  # (in dependent repos), will need to add these overrides.
  echo "echo CYBER_DOJO_EXERCISES_START_POINTS_SHA=$(git_commit_sha)"
  echo "echo CYBER_DOJO_EXERCISES_START_POINTS_TAG=$(git_commit_tag)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_kosli_create_flow
build_test_publish
on_ci_kosli_report_artifact
on_ci_kosli_assert_artifact # Return non-zero for non-compliant artifact
