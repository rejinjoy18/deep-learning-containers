#!/bin/bash

#/ Usage: 
#/ export AWS_REGION=<AWS-Region>
#/ export EKS_CLUSTER_MANAGER_ROLE=<ARN-of-IAM-role>
#/ ./delete.sh eks_cluster_name

set -ex

# Function to delete EKS cluster
function delete_cluster(){
    eksctl delete cluster \
    --name ${1} \
    --region ${2}
}

# Function to update kubeconfig at ~/.kube/config
function update_kubeconfig(){

    eksctl utils write-kubeconfig \
    --cluster ${1} \
    --authenticator-role-arn ${2} \
    --region ${3}
    kubectl config get-contexts
    
    cat /root/.kube/config
}

# Check for input arguments
if [ $# -ne 1 ]; then
    echo "usage: ./${0} eks_cluster_name"
    exit 1
fi

# Check for environment variables
if [ -z "${AWS_REGION}" ]; then
  echo "AWS region not configured"
  exit 1
fi

if [ -z "${EKS_CLUSTER_MANAGER_ROLE}" ]; then
  echo "EKS cluster management role not set"
  exit 1
fi

CLUSTER=${1}

update_kubeconfig ${CLUSTER} ${EKS_CLUSTER_MANAGER_ROLE} ${AWS_REGION}
delete_cluster ${CLUSTER} ${AWS_REGION}