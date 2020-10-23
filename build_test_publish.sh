#!/bin/bash -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo.exercises-start-points.XXXXXXXXX)
trap "rm -rf ${TMP_DIR} > /dev/null" INT EXIT

# - - - - - - - - - - - - - - - - - - - - - - - -
build_test_publish()
{
  exit_non_zero_unless_installed docker
  exit_non_zero_unless_installed git
  export $(versioner_env_vars)
  echo; remove_old_images
  echo; set_git_repo_dir
  echo; build_tagged_image
  assert_sha_env_var_inside_image_matches_image_tag
  echo; show_env_vars
  tag_the_image_to_latest
  echo; on_ci_publish_tagged_images
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
versioner_env_vars()
{
  # This function echoes env-vars which are exported and so become
  # available to the rest of the script. Start with the default env-vars...
  docker run --rm cyberdojo/versioner:latest
  # ... and then override the env-vars for exercises-start-points
  local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
  local -r tag="${sha:0:7}"
  echo "CYBER_DOJO_EXERCISES_START_POINTS_SHA=${sha}"
  echo "CYBER_DOJO_EXERCISES_START_POINTS_TAG=${tag}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  # When doing local development, tagging images from the git commit sha
  # will cause a lot of old images to build up unless they are deleted.
  local -r image_names=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_latest_images "${image_names}" "${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest_images()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in `echo "${docker_image_ls}" | grep "${name}:"`
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      if [ "${image_name}" != "${name}:<none>" ]; then
        docker image rm "${image_name}"
      fi
    fi
  done
  docker system prune --force
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_tagged_image()
{
  # GIT_COMMIT_SHA is needed to embed the SHA inside the created image as an env-var
  export GIT_COMMIT_SHA="$(image_sha)"
  $(cyber_dojo) start-point create "$(image_name):$(image_tag)" --exercises "${GIT_REPO_DIR}"
  unset GIT_COMMIT_SHA
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_sha_env_var_inside_image_matches_image_tag()
{
  local -r expected="$(image_sha)"
  local -r actual="$(docker run --entrypoint='' --rm "$(image_name):$(image_tag)" sh -c 'echo ${SHA}')"
  if [ "${expected}" != "${actual}" ]; then
    echo ERROR
    echo "expected:'${expected}'"
    echo "  actual:'${actual}'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name() { echo "${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}"; }
image_sha()  { echo "${CYBER_DOJO_EXERCISES_START_POINTS_SHA}"  ; }
image_tag()  { echo "${CYBER_DOJO_EXERCISES_START_POINTS_TAG}"  ; }

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
  docker tag "$(image_name):$(image_tag)" "$(image_name):latest"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
show_env_vars()
{
  # If you doing local development, your versioner_env_vars() function
  # (in dependent repos), will need to add these overrides.
  echo "CYBER_DOJO_EXERCISES_START_POINTS_SHA=$(image_sha)"
  echo "CYBER_DOJO_EXERCISES_START_POINTS_TAG=$(image_tag)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  # Docker login/logout is done in the .circleci/config.yml file
  docker push "$(image_name):$(image_tag)"
  docker push "$(image_name):latest"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_test_publish
