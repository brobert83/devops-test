#!/bin/bash

name=$(echo $1 | tr -cd "'[:alnum:]")

project=$2
service_account_name=$3
region=$4
zone=$5
frontend_port=$6
backend_port=$7

service_account_email=$(gcloud iam service-accounts list --filter="name:${service_account_name}" --format json | jq --raw-output '.[]| .email')

instance_template=${name}-instance-template
instance_group_name=${name}-mig
service_name=${name}-service
url_map_name=${name}-url-map
address_name=${name}-address
http_proxy_name=${name}-http-proxy
health_check_name=${name}-health-check
frontend_forwarding_rule=${name}-frontend-forwarding-rule
firewall_lb_allow_name=${name}-fw-allow-health-check-and-proxy
firewall_lb_allow_tag=${name}-allow-hc-and-proxy

echo -e "\n====== Creating environment: ${name} ======"

echo -e "\nCreate firewall rule"
gcloud compute firewall-rules create ${firewall_lb_allow_name} \
    --network=default \
    --action=allow \
    --direction=ingress \
    --target-tags=${firewall_lb_allow_tag} \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp:3000

echo -e "\nCreate IPv4 address"
gcloud compute addresses create ${address_name} \
    --ip-version=IPV4 \
    --global

echo -e "\nCreate instance template"
gcloud beta compute \
   --project=${project} instance-templates create ${instance_template} \
   --region=${region} \
   --machine-type=e2-micro \
   --network=projects/${project}/global/networks/default \
   --network-tier=PREMIUM \
   --maintenance-policy=MIGRATE \
   --service-account=${service_account_email} \
   --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
   --tags=http-server,${firewall_lb_allow_tag} \
   --image=ubuntu-1604-xenial-v20200923 \
   --image-project=ubuntu-os-cloud \
   --boot-disk-size=10GB \
   --boot-disk-type=pd-standard \
   --boot-disk-device-name=${instance_template} \
   --no-shielded-secure-boot \
   --shielded-vtpm \
   --shielded-integrity-monitoring \
   --reservation-affinity=any \
    --metadata=startup-script='#! /bin/bash
     apt-get update
     curl -sL https://deb.nodesource.com/setup_12.x | bash
     apt install nodejs'

echo -e "\nCreate instance group"
gcloud compute \
   --project=${project} instance-groups managed create ${instance_group_name} \
   --base-instance-name=${instance_group_name} \
   --template=${instance_template} \
   --size=2 \
   --zone=${zone}

echo -e "\nSet named port on instance group"
gcloud compute instance-groups unmanaged set-named-ports ${instance_group_name} \
    --named-ports http:${backend_port} \
    --zone ${zone}

echo -e "\nCreate health check"
gcloud compute health-checks create http ${health_check_name} --port ${backend_port}

echo -e "\nCreate backend service"
gcloud compute backend-services create ${service_name} \
    --global-health-checks \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=${health_check_name} \
    --global

echo -e "\nAdd instance group as backend to the backend service"
gcloud compute backend-services add-backend ${service_name} \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --capacity-scaler=1 \
    --instance-group=${instance_group_name} \
    --instance-group-zone=${zone} \
    --global

echo -e "\nCreate url map"
gcloud compute url-maps create ${url_map_name} \
    --default-service ${service_name}

echo -e "\nCreate http proxy"
gcloud compute target-http-proxies create ${http_proxy_name} \
    --url-map ${url_map_name}

echo -e "\nCreate frontend forwarding rule"
gcloud compute forwarding-rules create ${frontend_forwarding_rule} \
    --address=${address_name} \
    --global \
    --target-http-proxy=${http_proxy_name} \
    --ports=${frontend_port}

frontend_ip=$(gcloud compute forwarding-rules describe ${frontend_forwarding_rule} --format=json --global | jq --raw-output '.IPAddress')

echo -e "\nFrontend IP: ${frontend_ip}\n"
