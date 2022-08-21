#!/bin/bash -Eeu

readonly MERKELY_ENVIRONMENT="${1}"
readonly MERKELY_HOST="${2}"
readonly MERKELY_CHANGE=merkely/change:latest
readonly MERKELY_OWNER=cyber-dojo
readonly MERKELY_PIPELINE=exercises-start-points

# - - - - - - - - - - - - - - - - - - -
kosli_fingerprint()
{
  echo "docker://${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_log_deployment()
{
	docker run \
      --env MERKELY_COMMAND=log_deployment \
      --env MERKELY_OWNER=${MERKELY_OWNER} \
      --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
      --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
      --env MERKELY_DESCRIPTION="Deployed to ${MERKELY_ENVIRONMENT} in Github Actions pipeline" \
      --env MERKELY_ENVIRONMENT="${MERKELY_ENVIRONMENT}" \
      --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
      --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
      --env MERKELY_HOST="${MERKELY_HOST}" \
      --rm \
      --volume /var/run/docker.sock:/var/run/docker.sock \
    	    ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
export $(curl "${VERSIONER_URL}/app/.env")
export CYBER_DOJO_EXERCISES_START_POINTS_TAG="${CIRCLE_SHA1:0:7}"
docker pull ${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}

kosli_log_deployment
