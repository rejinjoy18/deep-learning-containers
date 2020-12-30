#!/bin/bash
set -e

#cluster upgrades
#https://eksctl.io/usage/cluster-upgrade/
#https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

#upgrade cluster autoscalar to the version matching the upgrade https://github.com/kubernetes/autoscaler/releases

function update_kubeconfig(){
    eksctl utils write-kubeconfig --name ${1} --region ${2}
    kubectl config get-contexts
}

function upgrade_eks_control_plane(){
    eksctl upgrade cluster --name=${1} --version ${2}
    eksctl upgrade cluster --name=${1} --version ${2} --approve
}

function scale_cluster_autoscalar(){
    kubectl scale deployments/cluster-autoscaler --replicas=${1} -n kube-system
}

function upgrade_autoscalar_image(){
    kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:$1
}

#upgrade control plane

function upgrade_nodegroups(){
    #create new nodegroups
    source ./eks_infra/create_cluster.sh 
    create_node_group ${1} ${2}

    #delete old nodegroups
    source ./eks_infra/delete_cluster.sh 
    delete_nodegroups ${1} ${3}
}

#Updating default add-ons
function update_eksctl_utils(){
    eksctl utils update-kube-proxy
    eksctl utils update-aws-node
    eksctl utils update-coredns
}

if [ $# -ne 4 ]; then
    echo $0: usage: ./upgrade_cluster.sh cluster_name eks_version cluster_autoscalar_image_version aws_region
    exit 1
fi

CLUSTER=$1
EKS_VERSION=$2
CLUSTER_AUTOSCALAR_IMAGE_VERSION=$3
REGION=$4

update_kubeconfig $CLUSTER $REGION

#scale to 0 to avoid unwanted scaling
scale_cluster_autoscalar 0

upgrade_autoscalar_image $EKS_VERSION
upgrade_eks_control_plane $CLUSTER $EKS_VERSION
upgrade_nodegroups $CLUSTER $EKS_VERSION $REGION
update_eksctl_utils

#scale back to 1
scale_cluster_autoscalar 1