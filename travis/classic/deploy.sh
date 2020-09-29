#!/bin/bash

name=$(echo $1 | tr -cd "'[:alnum:]")
zone=$2

instance_group_name=${name}-mig

echo -e "\n====== Deploying environment: ${name} ======"

gcloud compute instance-groups managed wait-until --stable --zone=${zone} ${instance_group_name}

for instance in $(gcloud compute instance-groups list-instances ${instance_group_name} --zone=${zone} --format="value(NAME)"); do

  echo "Deploying to ${instance}"

  gcloud compute ssh root@${instance} --zone=${zone} --command="killall node &>/dev/null || true "
  gcloud compute ssh root@${instance} --zone=${zone} --command="rm -rf /opt/buildit-devops-test || true"
  gcloud compute ssh root@${instance} --zone=${zone} --command="sudo mkdir -p /opt/buildit-devops-test"

  # this could definitely be done better
  gcloud compute scp \
    --strict-host-key-checking=no \
    --zone=${zone} \
    src/index.js \
    src/package.json \
    root@${instance}:/opt/buildit-devops-test \
    -q

done
