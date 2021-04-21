#!/bin/bash
set -e
export REPOSITORY=$(eval "REPO=$INPUT_REPOSITORY" && echo $REPO | sed 's/\//__/') # Replace '/' with '__', since labels don't support '/'

echo "----- Helm Info -----"
echo "Project: $INPUT_PROJECT"
echo "Zone: $INPUT_ZONE"
echo "Cluster: $INPUT_CLUSTER"
echo "Git Repo: $REPOSITORY"
echo "Helm Repo: $INPUT_GCS_HELM_REPO"
echo "Helm Version: $INPUT_HELM_VERSION"
echo "Helm Command: $INPUT_HELM_COMMAND"
echo "Helm Args: $INPUT_HELM_ARGS"
echo "-----"

echo "$INPUT_GCP_KEY" | base64 -d > /tmp/google_credentials.json
gcloud auth activate-service-account --key-file /tmp/google_credentials.json

export XDG_DATA_HOME=/helm3home
helm repo add gcs-repo "$INPUT_GCS_HELM_REPO"
helm repo update

gcloud container clusters get-credentials "$INPUT_CLUSTER" --zone "$INPUT_ZONE" --project "$INPUT_PROJECT"

export RELEASE_NAME=$(/applicationName.sh "$INPUT_HELM_ARGS")

echo "installing $RELEASE_NAME"

if [ $INPUT_HELM_VERSION == '3' ]
then
  helm_command=$(eval "echo $INPUT_HELM_COMMAND")
  echo "Running: helm $helm_command $INPUT_HELM_ARGS"
  helm $helm_command $INPUT_HELM_ARGS
else
  echo "helm version $INPUT_HELM_VERSION unsupported"
  exit 1
fi
