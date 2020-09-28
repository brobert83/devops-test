#!/bin/bash

namespace=$(echo $1 | tr -cd "'[:alnum:]")
version=$2
image=$3

[ "$(kubectl get namespaces -o json | jq -r ".items[] | select (.metadata.name==\"$namespace\") | .metadata.name")" != "${namespace}" ] && \
  echo "\n====== Creating namespace ${namespace} ======" && \
  kubectl create namespace ${namespace}

KUBE_NAMESPACE=${namespace} \
CONTAINER_VERSION=${version} \
IMAGE=${image} \
envsubst < travis/kubernetes/gke_template.yml > gke.yml

echo -e "\n======Deploying to namespace: ${namespace} ======"
cat gke.yml
echo

kubectl apply -f gke.yml
