#!/bin/bash
#/ Usage: ./env_setup.sh 

set -ex

# aws caller identity
aws sts get-caller-identity

#aws-iam-authenticator version
aws-iam-authenticator version

# install aws-iam-authenticator
if ! [ -x "$(command -v aws-iam-authenticator)" ]; then
    curl --silent --location https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator
    chmod +x /usr/local/bin/aws-iam-authenticator
fi

#aws-iam-authenticator version
aws-iam-authenticator version

# install kubectl
if ! [ -x "$(command -v kubectl)" ]; then
    curl --silent --location https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
    chmod +x /usr/local/bin/kubectl
fi

#kubectl version
kubectl version --short --client

#temp changes
curl --silent --location https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

#kubectl version
kubectl version --short --client

# install eksctl

# TODO: rolling the eksctl version to 0.34.0 due to a bug https://github.com/weaveworks/eksctl/issues/3005 causing the nodes not joining cluster
# as kubelet service on worker node fails. Fix included in v0.36.0 which is in pre-release state
# "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"

if ! [ -x "$(command -v eksctl)" ]; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.34.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    mv /tmp/eksctl /usr/local/bin
fi

#eksctl version
eksctl version