#!/bin/bash
set -e

if [ $# -ne 3 ]; then
    echo $0: usage: ./install_cluster_components.sh cluster_name cluster_autoscalar_image_version aws_region
    exit 1
fi

CLUSTER_NAME=$1
CLUSTER_AUTOSCALAR_IMAGE_VERSION=$2
REGION=$3

#install cluster autoscalar
kubectl apply -f cluster-autoscalar-autodiscover.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

sed -e 's/<CLUSTER_NAME>/'"$CLUSTER_NAME"'/g;s/<VERSION>/'"$CLUSTER_AUTOSCALAR_IMAGE_VERSION"'/g' cluster-autoscalar-autodiscover.yaml > /tmp/cluster-autoscalar-autodiscover-$CLUSTER_NAME.yaml &&
kubectl replace -f /tmp/cluster-autoscalar-autodiscover-$CLUSTER_NAME.yaml


#install kubeflow

./install_kubeflow_custom_kfctl.sh $CLUSTER_NAME $REGION
