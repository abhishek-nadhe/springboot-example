#!/bin/bash

echo START: $(date)
export SERVICE_NAME="springboot-latest"
export API_VERSION="v2.0"
export IMAGE_TAG=${API_VERSION}
export IMAGE=${SERVICE_NAME}
export CONTAINER_NAME=${SERVICE_NAME}-${API_VERSION}

if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed"
    # command
else
    echo "Installing Docker"
    sudo apt-get update -y
    sudo apt  install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    newgrp docker
fi

cwd=$(pwd)

echo "Stopping existing container"
container_id=$(docker ps -a | grep {CONTAINER-NAME} | awk '{print $1}')
if [ ! -z "$container_id" ]; then
    docker stop "$container_id"
fi

echo "Removing existing container"
docker rm {CONTAINER-NAME}

echo "Removing existing image"
docker rmi {ECR-REPO-URL}:{CONTAINER-NAME}

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com

docker pull {ECR-REPO-URL}:{CONTAINER-NAME}

echo "Running new container"
docker run -d --name {CONTAINER-NAME} --network=host --restart unless-stopped {ECR-REPO-URL}:{CONTAINER-NAME}

cd $cwd

echo FINISH: $(date)
