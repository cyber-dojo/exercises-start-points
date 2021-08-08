#!/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly MERKELY_CHANGE=merkely/change:latest
readonly MERKELY_OWNER=cyber-dojo
readonly MERKELY_PIPELINE=exercises-start-points

# - - - - - - - - - - - - - - - - - - -
merkely_fingerprint()
{
  echo "docker://${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_deployment()
{
  local -r ENVIRONMENT="${1}"
  local -r HOSTNAME="${2}"

  VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
  export $(curl "${VERSIONER_URL}/app/.env")
  export CYBER_DOJO_EXERCISES_START_POINTS_TAG="${CIRCLE_SHA1:0:7}"
  docker pull ${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}

	docker run \
      --env MERKELY_COMMAND=log_deployment \
      --env MERKELY_OWNER=${MERKELY_OWNER} \
      --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
      --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
      --env MERKELY_DESCRIPTION="Deployed to ${environment} in circleci pipeline" \
      --env MERKELY_ENVIRONMENT="${ENVIRONMENT}" \
      --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
      --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
      --env MERKELY_HOST="${HOSTNAME}" \
      --rm \
      --volume /var/run/docker.sock:/var/run/docker.sock \
    	    ${MERKELY_CHANGE}
}