#!/bin/bash
# shellcheck disable=SC1072,SC1073,SC1064
set -e
export REPOSITORY="$(eval "REPO=$INPUT_REPOSITORY" && echo $REPO" | sed 's/\//__/') # Replace '/' with '__', since labels don't support '/'

echo "----- Helm Info -----"
echo "Project: $INPUT_PROJECT"
echo "Zone: $INPUT_ZONE"
echo "Cluster: $INPUT_CLUSTER"
echo "Git Repo: $REPOSITORY"
echo "Helm OCI: $INPUT_OCI_HELM_REPO"
echo "Helm OCI_Version: $INPUT_OCI_CHART_VERSION"
echo "Helm Version: $INPUT_HELM_VERSION"
echo "Helm Command: $INPUT_HELM_COMMAND"
echo "Helm Args: $INPUT_HELM_ARGS"
echo "-----"

echo "$INPUT_GCP_KEY | base64 -d > /tmp/google_credentials.json"
gcloud auth activate-service-account --key-file /tmp/google_credentials.json

export XDG_DATA_HOME=/helm3home
helm pull "$INPUT_OCI_HELM_REPO" --version "$INPUT_OCI_CHART_VERSION"
#helm repo update
gcloud auth configure-docker
gcloud container clusters get-credentials "$INPUT_CLUSTER" --zone "$INPUT_ZONE" --project "$INPUT_PROJECT"

readonly export RELEASE_NAME=$(/applicationName.sh "$INPUT_HELM_ARGS")
echo "Release name: $RELEASE_NAME"

timestamp="$(date -d@"$(( $(date+%s)+300))" '+%FT%T.3Z')"
log_url="https://console.cloud.google.com/logs/query;query=resource.labels.project_id%3D%22$INPUT_PROJECT%22%0Aresource.labels.location%3D%22$INPUT_ZONE%22%0Aresource.labels.cluster_name%3D%22$INPUT_CLUSTER%22%0A%22$RELEASE_NAME%22;cursorTimestamp=$timestamp?project=$INPUT_PROJECT"
echo "GCP logs:  $log_url"
echo "::set-output name=log_url::$log_url"


HELM_COMMAND_ARRAY="$(eval "echo $INPUT_HELM_COMMAND")"
declare -a 'HELM_ARGS_ARRAY=('("$INPUT_HELM_ARGS")')
helm "${helm_command_array[@]}" "${helm_args_array[@]}"