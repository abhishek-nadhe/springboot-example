#!/bin/bash

# Configure AWS credentials
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"

S3_BUCKET="demo-bucket-spring"
S3_PATH="docker_images"

DOCKER_IMAGE_NAME="springboot"

ECR_REGION="$AWS_DEFAULT_REGION"
ECR_ACCOUNT_ID="$AWS_ACCOUNT_ID"
ECR_REPOSITORY_NAME="kampdevecr"
ECR_TAG="springboot"

# Download the Docker image from S3
aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}/${DOCKER_IMAGE_NAME}.tar.gz" "${GITHUB_WORKSPACE}/${DOCKER_IMAGE_NAME}.tar.gz"

#Load the Docker image
docker load -i "${GITHUB_WORKSPACE}/${DOCKER_IMAGE_NAME}.tar.gz"

echo "Loaded image ID: $(docker images -q ${DOCKER_IMAGE_NAME}:latest)"

aws ecr get-login-password --region "$AWS_DEFAULT_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"

docker tag "${DOCKER_IMAGE_NAME}:latest" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_REPOSITORY_NAME}:${ECR_TAG}"

docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/${ECR_REPOSITORY_NAME}:${ECR_TAG}"

docker rmi "${DOCKER_IMAGE_NAME}:latest"

echo "Docker image ${DOCKER_IMAGE_NAME} has been pushed to ECR successfully!"
