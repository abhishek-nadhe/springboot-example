#!/bin/bash

# Docker image details
IMAGE_NAME="springboot"
TAG="latest"

# S3 details
S3_BUCKET="demo-bucket-spring"
S3_PATH="docker_images"

# Build Docker image
docker build -t "${IMAGE_NAME}:${TAG}" .

# Save Docker image as a .tar file
docker save -o "${IMAGE_NAME}.tar" "${IMAGE_NAME}:${TAG}"

# Compress the .tar file to .tar.gz
gzip "${IMAGE_NAME}.tar"

# Upload to S3 bucket
aws s3 cp "${IMAGE_NAME}.tar.gz" "s3://${S3_BUCKET}/${S3_PATH}/"

# Clean up: remove local .tar and .tar.gz files
rm "${IMAGE_NAME}.tar.gz"
