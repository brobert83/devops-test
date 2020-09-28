#!/bin/bash

namespace=$(echo $1 | tr -cd "'[:alnum:]")
version=$2
project=$3
cluster_name=$4

[ "$(kubectl get namespaces -o json | jq -r ".items[] | select (.metadata.name==\"$namespace\") | .metadata.name")" != "${namespace}" ] && \
  echo "\n====== Creating namespace ${namespace} ======" && \
  kubectl create namespace ${namespace}

KUBE_NAMESPACE=${namespace} \
CONTAINER_VERSION=${version} \
PROJECT_NAME=${project} \
CLUSTER_NAME=${cluster_name} \
envsubst < travis/kubernetes/gke_template.yml > gke.yml

echo -e "\n======Deploying to namespace: ${namespace} ======"
cat gke.yml

kubectl apply -f gke.yml
