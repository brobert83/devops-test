#!/bin/bash

namespace=$1

kubectl delete -n ${namespace} pod,svc,ingress --all

kubectl delete namspace ${namespace}