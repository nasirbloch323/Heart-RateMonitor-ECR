#!/usr/bin/env bash
# Usage: ./push-to-ecr.sh [tag]
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"      # apna region likhein
REPO_NAME="${REPO_NAME:-devops-portfolio}"
TAG="${1:-latest}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/${REPO_NAME}:${TAG}"

# 1. repo na ho to bana do
aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$AWS_REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$REPO_NAME" --region "$AWS_REGION" \
       --image-scanning-configuration scanOnPush=true

# 2. ECR login
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"

# 3. build + tag + push
docker build -t "${REPO_NAME}:${TAG}" .
docker tag "${REPO_NAME}:${TAG}" "$IMAGE"
docker push "$IMAGE"

echo "Pushed: $IMAGE"
