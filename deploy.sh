#!/bin/bash
set -e
export GCP_KEY="$INPUT_GCP_KEY"
export ZONE="$INPUT_ZONE"
export PROJECT="$INPUT_PROJECT"
export CLUSTER="$INPUT_CLUSTER"
export GCS_HELM_REPO="$INPUT_GCS_HELM_REPO"
export HELM_VERSION="$INPUT_HELM_VERSION"
export HELM_ARGS="$INPUT_HELM_ARGS"
export HELM_COMMAND="$INPUT_HELM_COMMAND"
export REPOSITORY=$(eval "REPO=$INPUT_REPOSITORY" && echo $REPO | sed 's/\//__/') # Replace '/' with '__', since labels don't support '/'

echo -----
echo "$ZONE"
echo "$PROJECT"
echo "$CLUSTER"
echo "$REPOSITORY"
echo "$GCS_HELM_REPO"
echo "$HELM_VERSION"
echo "$HELM_ARGS"
echo "$HELM_COMMAND"
echo -----

echo "$GCP_KEY" | base64 -d > /tmp/google_credentials.json
gcloud auth activate-service-account --key-file /tmp/google_credentials.json

export XDG_DATA_HOME=/helm3home
helm repo add gcs-repo "$GCS_HELM_REPO"
helm repo update

gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE" --project "$PROJECT"

export RELEASE_NAME=$(/applicationName.sh "$HELM_ARGS")

echo "installing $RELEASE_NAME"

if [ $HELM_VERSION == '3' ]
then
  suffix=$(eval "array=($HELM_COMMAND)"; for arg in "${array[@]}"; do echo "$arg"; done )
  echo "Will run: helm $suffix"
  helm $(eval "array=($HELM_COMMAND)"; for arg in "${array[@]}"; do echo "$arg"; done )
else
  echo "helm version $VERSION unsupported"
  exit 1
fi
