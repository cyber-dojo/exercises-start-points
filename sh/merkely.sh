#!/bin/bash -Eeu

# ROOT_DIR must be set

readonly MERKELY_CHANGE=merkely/change:latest
readonly MERKELY_OWNER=cyber-dojo
readonly MERKELY_PIPELINE=exercises-start-points


# - - - - - - - - - - - - - - - - - - -
merkely_fingerprint()
{
  echo "docker://${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
merkely_declare_pipeline()
{
  local -r hostname="${1}"

  docker run \
  	--env MERKELY_COMMAND=declare_pipeline \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
	  --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
	  --rm \
	  --volume ${ROOT_DIR}/Merkelypipe.json:/data/Merkelypipe.json \
		  ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_artifact()
{
  local -r hostname="${1}"

  docker run \
    --env MERKELY_COMMAND=log_artifact \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_ARTIFACT_GIT_COMMIT=${CYBER_DOJO_EXERCISES_START_POINTS_SHA} \
    --env MERKELY_ARTIFACT_GIT_URL=https://github.com/${MERKELY_OWNER}/${MERKELY_PIPELINE}/commit/${CYBER_DOJO_EXERCISES_START_POINTS_SHA} \
    --env MERKELY_CI_BUILD_NUMBER=${CIRCLE_BUILD_NUM} \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}

# - - - - - - - - - - - - - - - - - - -
on_ci_merkely_declare_pipeline()
{
  if ! on_ci ; then
    return
  fi

  merkely_declare_pipeline https://staging.app.merkely.com
  merkely_declare_pipeline https://app.merkely.com
}

# - - - - - - - - - - - - - - - - - - -
on_ci_merkely_log_artifact()
{
  if ! on_ci ; then
    return
  fi

  merkely_log_artifact https://staging.app.merkely.com
  merkely_log_artifact https://app.merkely.com
}


