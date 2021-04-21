#!/bin/bash
set -e

export HELM_ARGS=$1

export FILES=""

eval "array=($HELM_ARGS)";
for i in "${!array[@]}"; do
  value="${array[$i]}"
  if [ "$value" == '-f' ]
  then
    export FILES="$FILES ${array[$i+1]}"
  elif [[ "$value" == applicationName=* ]]
  then
    export APPLICATION_NAME=$(echo "$value" | sed 's/applicationName=//g')
    echo $APPLICATION_NAME
    exit 0
  elif [[ "$value" == application.name=* ]]
  then
    export APPLICATION_NAME=$(echo "$value" | sed 's/application.name=//g')
    echo $APPLICATION_NAME
    exit 0
  fi
done

eval "fileArray=($FILES)";

if [ ${#fileArray[@]} = 0 ]
then
  echo "NO APPLICATION_NAME :("
  exit 1
fi

# If more than one values file, reverse the order and merge them in a temporary file.
if [ ${#fileArray[@]} -gt 1 ]
then
  REVERSED_FILES=$(echo $FILES | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }')
  yq m $REVERSED_FILES > "tmp.yaml"
  VALUES="tmp.yaml"
else
  VALUES=$FILES
fi

# Check if new or old naming convention exists.
OLD_NAME=$(cat $VALUES | yq r - applicationName)
NEW_NAME=$(cat $VALUES | yq r - application.name)
if [ ! $OLD_NAME = "null" ]
then
  export APPLICATION_NAME=$OLD_NAME
elif [ ! $NEW_NAME = "null" ]
then
  export APPLICATION_NAME=$NEW_NAME
else
  echo "NO APPLICATION_NAME :("
  exit 1
fi

echo $APPLICATION_NAME
