FILES=""
eval "fileArray=($FILES)";

if [ ${#fileArray[@]} = 0 ]
then
  echo "NO APPLICATION_NAME :("
  exit 1
fi

# If more than one values file, reverse the order and merge them.
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
if [ ! -z $OLD_NAME ]
then
  APPLICATION_NAME=$OLD_NAME
elif [ ! -z $NEW_NAME ]
then
  APPLICATION_NAME=$NEW_NAME
else
  echo "NO APPLICATION_NAME :("
  exit 1
fi

echo $APPLICATION_NAME