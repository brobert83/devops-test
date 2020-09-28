#!/bin/bash

namespace=$1
version=$2

[ "$(kubectl get namespaces -o json | jq -r ".items[] | select (.metadata.name==\"$namespace\") | .metadata.name")" != "${namespace}" ] && \
  echo "\n====== Creating namespace ${namespace} ======" && \
  kubectl create namespace ${namespace}

KUBE_NAMESPACE=${namespace} CONTAINER_VERSION=${version} envsubst < travis/kubernetes/gke_template.yml > gke.yml

echo -e "\n======Deploying to namespace: ${namespace} ======"
cat gke.yml

kubectl apply -f gke.yml
