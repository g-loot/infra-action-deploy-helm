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
echo "Release name: $RELEASE_NAME"

date_time=`date -u "+%FT%T.%3Z"`
log_url="https://console.cloud.google.com/logs/query;query=resource.labels.project_id%3D%22$INPUT_PROJECT%22%0Aresource.labels.location%3D%22$INPUT_ZONE%22%0Aresource.labels.cluster_name%3D%22$INPUT_CLUSTER%22%0A%22$RELEASE_NAME%;cursorTimestamp=$date_time?project=$INPUT_PROJECT"
echo "GCP logs:  $log_url"
echo "::set-output name=log_url::$log_url"

if [ $INPUT_HELM_VERSION == '3' ]
then
  helm_command_array=($(eval "echo $INPUT_HELM_COMMAND"))
  declare -a 'helm_args_array=('"$INPUT_HELM_ARGS"')'
  helm "${helm_command_array[@]}" "${helm_args_array[@]}"
else
  echo "helm version $INPUT_HELM_VERSION unsupported"
  exit 1
fi
