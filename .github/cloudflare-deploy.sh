#!/bin/bash
set -e
PROJECT=$1
DEFAULT_BRANCH=$2
DIST=$3
CURRENT_BRANCH=$4

IFS='/' read -ra fields <<<"$PROJECT"
REPOSITORY_NAME="${fields[1]}"
REPOSITORY_NAME=${REPOSITORY_NAME//./-}

echo "Checking if project exists..."

CLOUDFLARE_ACCOUNT_ID="17b9dfa79e16b79dffcb11a66768539c"

# Fetch the list of projects and check if the specific project exists
project_exists=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r ".result[] | select(.name == \"$REPOSITORY_NAME\") | .name")

if [ "$project_exists" == "$REPOSITORY_NAME" ]; then
  echo "Project already exists. Skipping creation..."
else
  echo "Project does not exist. Creating new project..."
  # Curl command to create a new project
  curl -X POST "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"name\":\"$REPOSITORY_NAME\",\"production_branch\":\"$DEFAULT_BRANCH\",\"build_config\":{\"build_command\":\"\",\"destination_dir\":\"$DIST\"}}"
fi


yarn add wrangler
output_url=$(yarn wrangler pages deploy "$DIST" --project-name "$REPOSITORY_NAME" --branch "$CURRENT_BRANCH" --commit-dirty=true)
output_url="${output_url//$'\n'/%0A}"
echo "DEPLOYMENT_OUTPUT=$output_url" >>"$GITHUB_ENV"
