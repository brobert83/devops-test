#!/bin/bash

project=$1
zone=$2
cluster_name=$3

# Create the cluster if it does not exist
[ "$(gcloud container clusters list --filter="name:${cluster_name}" --format="get(NAME)")" != "${cluster_name}" ] && \
  echo -e "\n====== Creating GKE cluster: ${cluster_name} ======" && \
  gcloud container clusters create "${cluster_name}" \
    --project "${project}" \
    --zone "${zone}" \
    --no-enable-basic-auth \
    --cluster-version "1.15.12-gke.20" \
    --machine-type "e2-medium" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only", \
             "https://www.googleapis.com/auth/logging.write", \
             "https://www.googleapis.com/auth/monitoring", \
             "https://www.googleapis.com/auth/servicecontrol", \
             "https://www.googleapis.com/auth/service.management.readonly", \
             "https://www.googleapis.com/auth/trace.append" \
    --num-nodes "3" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --network "projects/buildit-devops-test/global/networks/default" \
    --subnetwork "projects/buildit-devops-test/regions/us-central1/subnetworks/default" \
    --default-max-pods-per-node "8" \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --enable-autoupgrade \
    --enable-autorepair \
    --max-surge-upgrade 1

gcloud container clusters get-credentials ${clustername}
