#!/bin/bash -Eeu

apk update
apk add curl
apk add python3
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-337.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-sdk-337.0.0-linux-x86_64.tar.gz
cd google-cloud-sdk
./install.sh -q
source ./path.bash.inc

readonly K8S_URL=https://raw.githubusercontent.com/cyber-dojo/k8s-install/master
source <(curl "${K8S_URL}/sh/deployment_functions.sh")

gcloud_init