#!/bin/bash
set -o xtrace

if grep -q imageGCHighThresholdPercent /etc/kubernetes/kubelet/kubelet-config.json;
then
    sudo sed -i 's/"imageGCHighThresholdPercent":.*/"imageGCHighThresholdPercent": 50,/' /etc/kubernetes/kubelet/kubelet-config.json
else
    sudo sed -i '/"apiVersion*/a \ \ "imageGCHighThresholdPercent": 50,' /etc/kubernetes/kubelet/kubelet-config.json
fi

if grep -q imageGCLowThresholdPercent /etc/kubernetes/kubelet/kubelet-config.json;
then
    sudo sed -i 's/"imageGCLowThresholdPercent":.*/"imageGCLowThresholdPercent": 40,/' /etc/kubernetes/kubelet/kubelet-config.json
else
    sudo sed -i '/"apiVersion*/a \ \ "imageGCLowThresholdPercent": 40,' /etc/kubernetes/kubelet/kubelet-config.json
fi

/etc/eks/bootstrap.sh ${eks_cluster_name} --container-runtime containerd