#!/usr/bin/env bash

set -ex

image="qwinixtechnologies/k8s-skaffold"
repo="GoogleContainerTools/skaffold"

latest=$(curl -sL https://api.github.com/repos/${repo}/releases/latest | jq -r '.tag_name' | sed 's/^v//')

echo "Latest stable release of Skaffold is: ${latest}"

docker_tags=$(curl -sL https://hub.docker.com/v2/repositories/qwinixtechnologies/k8s-skaffold/tags | jq -r .results[].name)

tag_exists=0

for tag in ${docker_tags[@]}; do
    if [ "$tag" == "$latest" ]; then
        echo "$tag already appears to have been pushed to registry"
        tag_exists=1
    fi
done

if [[ ($tag_exists -ne 1) ]]; then # TODO: Add rebuild force
    docker build --no-cache --build-arg SKAFFOLD_VERSION=$latest -t ${image}:${latest} .

    # Validate versioning
    build_version=$(docker run -it --rm ${image}:${latest} version | tr -d '\r')

    if [ "${build_version}" == "v${latest}" ]; then
        echo "Applying latest tag"
        docker tag ${image}:${latest} ${image}:latest

        docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

        echo "Pushing validated image to registry..."
        docker push ${image}:${latest}
        docker push ${image}:latest
    fi
else
    echo "Skipping image creation, version already exists."
fi