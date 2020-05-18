#!/bin/bash
set -e
export GCP_KEY="$INPUT_GCP_KEY"
export ZONE="$INPUT_ZONE"
export PROJECT="$INPUT_PROJECT"
export CLUSTER="$INPUT_CLUSTER"
export HELM_REPO="$INPUT_HELM_REPO"
export HELM_VERSION="$INPUT_HELM_VERSION"
export HELM_ARGS="$INPUT_HELM_ARGS"
export HELM_CHART="$INPUT_HELM_CHART"
export HELM_COMMAND="$INPUT_HELM_COMMAND"
export SERVICE_REPO=$(eval "REPO=$INPUT_SERVICE_REPO" && echo $REPO | sed 's/\//__/') # Replace '/' with '__', since labels don't support '/'

echo -----
echo "Zone: $ZONE"
echo "Project: $PROJECT"
echo "Cluster: $CLUSTER"
echo "Service repo: $SERVICE_REPO"
echo "Helm repo: $HELM_REPO"
echo "Helm version: $HELM_VERSION"
echo "Helm args: $HELM_ARGS"
echo "Helm chart: $HELM_CHART"
echo "Helm command: $HELM_COMMAND"
echo -----

echo "$GCP_KEY" | base64 -d > /tmp/google_credentials.json
gcloud auth activate-service-account --key-file /tmp/google_credentials.json

export HELM_HOME=/helm2home
helm2 repo add repo "$HELM_REPO"
helm2 repo update

export XDG_DATA_HOME=/helm3home
helm3 repo add repo "$HELM_REPO"
helm3 repo update

gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE" --project "$PROJECT"

export RELEASE_NAME=$(/applicationName.sh "$HELM_ARGS" )

echo "installing $RELEASE_NAME"

if [ $HELM_VERSION == '2' ]
then
  helm2 $(eval "array=($HELM_COMMAND)"; for arg in "${array[@]}"; do echo "$arg"; done )
elif [ $HELM_VERSION == '3' ]
then
  helm3 $(eval "array=($HELM_COMMAND)"; for arg in "${array[@]}"; do echo "$arg"; done )
else
  echo "helm version $VERSION unsupported"
  exit 1
fi
