#!/bin/bash

set -e

ACCOUNT_ID="your-account-id"
REGION="your-region"
REPOSITORY="hello-world"
RELEASE_TAG="latest"
IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:$RELEASE_TAG"

docker build -t "$REPOSITORY:$RELEASE_TAG" .
docker tag "$REPOSITORY:$RELEASE_TAG" "$IMAGE_URI"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
docker push "$IMAGE_URI"