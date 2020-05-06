export RELEASE_NAME=$(/Users/g-loot/Dev/infra/action-deploy-helm/applicationName.sh "-f values.yaml --set image.tag=latest")

echo "$RELEASE_NAME"