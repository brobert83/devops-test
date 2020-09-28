#!/bin/bash

namespace=$1

echo -e "\n====== Waiting for environment to become available: ${namespace} ======"

frontend_ip=$(kubectl -n ${namespace} get service devops-test -o json | jq -r '.status.loadBalancer.ingress[0].ip')

until $(curl --output /dev/null --silent --head --fail http://${frontend_ip}); do
    echo -n '.'
    sleep 5
done

echo -e "\n====== Deployment done, visit http://${frontend_ip} ======"
