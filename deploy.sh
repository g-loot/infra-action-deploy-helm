#!/bin/bash
set -e
export GCP_KEY=$INPUT_GCP_KEY
export ZONE=$INPUT_ZONE
export PROJECT=$INPUT_PROJECT
export CLUSTER=$INPUT_CLUSTER
export GCS_HELM_REPO=$INPUT_GCS_HELM_REPO
export HELM_VERSION=$INPUT_HELM_VERSION
export HELM_APPLICATION_NAME=$INPUT_APPLICATION_NAME
export HELM_ARGS=$INPUT_HELM_ARGS
export HELM_COMMAND=$INPUT_HELM_COMMAND

echo -----
echo $ZONE
echo $PROJECT
echo $CLUSTER
echo $GCS_HELM_REPO
echo $HELM_VERSION
echo $HELM_APPLICATION_NAME
echo $HELM_ARGS
echo $HELM_COMMAND
echo -----

echo $GCP_KEY | base64 -d > /tmp/google_credentials.json
gcloud auth activate-service-account --key-file /tmp/google_credentials.json

helm2 init --client-only
helm2 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0
helm2 repo add gcs-repo $GCS_HELM_REPO
helm2 repo update

helm3 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0
helm3 repo add gcs-repo $GCS_HELM_REPO
helm3 repo update

gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT

if [ $HELM_VERSION == '2' ]
then
  helm2 $(eval "array=($HELM_COMMAND)"; for arg in "${array[@]}"; do echo "$arg"; done)
elif [ $HELM_VERSION == '3' ]
then
  helm3 $(eval "array=($HELM_COMMAND)"; for arg in "${array[@]}"; do echo "$arg"; done)
else
  echo "helm version $VERSION unsupported"
  exit 1
fi
