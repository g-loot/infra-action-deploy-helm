#!/bin/bash
set -e
export REPOSITORY=$(eval "REPO=$INPUT_REPOSITORY" && echo $REPO | sed 's/\//__/') # Replace '/' with '__', since labels don't support '/'

echo "----- Helm Info -----"
echo "Project: $INPUT_PROJECT"
echo "Helm Repo: $INPUT_GCS_HELM_REPO"
echo "Helm Version: $INPUT_HELM_VERSION"
echo "Helm Command: $INPUT_HELM_COMMAND"
echo "-----"

echo "$INPUT_GCP_KEY" | base64 -d > /tmp/google_credentials.json
gcloud auth activate-service-account --key-file /tmp/google_credentials.json

export XDG_DATA_HOME=/helm3home
#helm repo add gcs-repo "$INPUT_GCS_HELM_REPO"
#helm repo update
if [ $INPUT_HELM_VERSION == '3.9.0' ]
then
  helm_command_array=($(eval "echo $INPUT_HELM_COMMAND"))
  declare -a 'helm_args_array=('"$INPUT_HELM_ARGS"')'
  helm "${helm_command_array[@]}" "${helm_args_array[@]}"
else
  echo "helm version $INPUT_HELM_VERSION unsupported"
  exit 1
fi
