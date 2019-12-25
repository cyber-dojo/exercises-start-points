
[![CircleCI](https://circleci.com/gh/cyber-dojo/exercises-start-points.svg?style=svg)](https://circleci.com/gh/cyber-dojo/exercises-start-points)

Specifies the start-points used to create the exercises start-points image
* [cyberdojo/exercises-start-points](https://hub.docker.com/r/cyberdojo/exercises-start-points)

```bash
#!/bin/bash
set -e
# The script to run
GITHUB_ORG=https://raw.githubusercontent.com/cyber-dojo
REPO=commander
BRANCH=master
SCRIPT=cyber-dojo
curl -O --silent --fail "${GITHUB_ORG}/${REPO}/${BRANCH}/${SCRIPT}"
chmod 700 ./${SCRIPT}
# The name of the image to create...
IMAGE_NAME=cyberdojo/exercises-start-points:latest
# From this repo's url
GIT_REPO_URL=https://github.com/cyber-dojo/exercises-start-points.git

./${SCRIPT} start-point create \
   "${IMAGE_NAME}" \
    --exercises \
      "${GIT_REPO_URL}"        
```

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
