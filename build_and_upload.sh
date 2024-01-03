#!/bin/bash

IMAGE_NAME="springboot"
TAG="latest"

S3_BUCKET="demo-bucket-spring"
S3_PATH="docker_images"

docker build -t "${IMAGE_NAME}:${TAG}" .

docker save -o "${IMAGE_NAME}.tar" "${IMAGE_NAME}:${TAG}"

gzip "${IMAGE_NAME}.tar"

aws s3 cp "${IMAGE_NAME}.tar.gz" "s3://${S3_BUCKET}/${S3_PATH}/"

rm "${IMAGE_NAME}.tar.gz"
