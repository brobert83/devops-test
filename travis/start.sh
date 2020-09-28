#!/bin/bash

name=$(echo $1 | tr -cd "'[:alnum:]")
zone=$2

instance_group_name=${name}-mig

echo -e "\n====== Starting environment: ${name} ======"

gcloud compute instance-groups managed wait-until --stable --zone=${zone} ${instance_group_name}

# I don't know why but sometimes it does't work, so wait a bit (the frontend takes time to become available anyway)
# it should be ok, the file copy works fine
sleep 30

for instance in $(gcloud compute instance-groups list-instances ${instance_group_name} --zone=${zone} --format="value(NAME)"); do

  echo "Starting app on ${instance}"

  gcloud compute ssh root@${instance} --command="cd /opt/buildit-devops-test && screen -dm npm start" --zone=${zone}

done
