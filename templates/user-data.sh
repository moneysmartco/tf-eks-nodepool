#!/bin/bash
set -o xtrace

LOG_FILE="/var/log/eks-bootstrap.log"
{
# Inject imageGCHighThresholdPercent value unless it has already been set.
if ! grep -q imageGCHighThresholdPercent /etc/kubernetes/kubelet/kubelet-config.json;
then
    sudo sed -i '/"apiVersion*/a \ \ "imageGCHighThresholdPercent": 50,' /etc/kubernetes/kubelet/kubelet-config.json
fi

# Inject imageGCLowThresholdPercent value unless it has already been set.
if ! grep -q imageGCLowThresholdPercent /etc/kubernetes/kubelet/kubelet-config.json;
then
    sudo sed -i '/"imageGCHigh*/a \ \ "imageGCLowThresholdPercent": 40,' /etc/kubernetes/kubelet/kubelet-config.json
fi

    /etc/eks/bootstrap.sh ${eks_cluster_name} --container-runtime containerd
} >> "$LOG_FILE" 2>&1