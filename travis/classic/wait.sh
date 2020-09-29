#!/bin/bash

name=$(echo $1 | tr -cd "'[:alnum:]")

frontend_forwarding_rule=${name}-frontend-forwarding-rule

echo -e "\n====== Waiting for environment to become available: ${name} at http://${frontend_ip} ======"

frontend_ip=$(gcloud compute forwarding-rules describe ${frontend_forwarding_rule} --format=json --global | jq --raw-output '.IPAddress')

until $(curl --output /dev/null --silent --head --fail http://${frontend_ip}); do
    echo -n '.'
    sleep 5
done

echo -e "\nDeployment done, visit http://${frontend_ip}"
