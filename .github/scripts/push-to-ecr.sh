#!/bin/bash

# Set your S3 bucket details
S3_BUCKET="demo-bucket-spring"
S3_PATH="docker_images"

# Set the Docker image name to pick from S3
DOCKER_IMAGE_NAME="device-mgmt"

# Set your ECR repository details
ECR_REGION="${{ secrets.AWS_DEFAULT_REGION }}"
ECR_ACCOUNT_ID="${{ secrets.AWS_ACCOUNT_ID }}"
ECR_REPOSITORY_URI="${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/kampdevecr"
ECR_TAG="device-mgmt"

# Step 1: Download the Docker image from S3
aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}/${DOCKER_IMAGE_NAME}.tar.gz" "${GITHUB_WORKSPACE}/${DOCKER_IMAGE_NAME}.tar.gz"

# Step 2: Load the Docker image
docker load -i "${GITHUB_WORKSPACE}/${DOCKER_IMAGE_NAME}.tar.gz"

# Step 3: Tag the Docker image
docker tag ${DOCKER_IMAGE_NAME}:tag "${ECR_REPOSITORY_URI}:${ECR_TAG}"

# Step 4: Authenticate Docker to the ECR registry
aws ecr get-login-password --region "${ECR_REGION}" | docker login --username AWS --password-stdin "${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com"

# Step 5: Push the Docker image to ECR
docker push "${ECR_REPOSITORY_URI}:${ECR_TAG}"

# Clean up: Remove the local Docker image
docker rmi ${DOCKER_IMAGE_NAME}:tag

echo "Docker image ${DOCKER_IMAGE_NAME} has been pushed to ECR successfully!"
