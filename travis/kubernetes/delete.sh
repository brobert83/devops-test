#!/bin/bash

namespace=$(echo $1 | tr -cd "'[:alnum:]")

kubectl delete -n ${namespace} pod,svc,ingress --all

kubectl delete namespace ${namespace}