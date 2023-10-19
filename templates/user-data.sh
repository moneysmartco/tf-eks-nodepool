#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${eks_cluster_name} ${bootstrap_arguments} --container-runtime containerd --kubelet-extra-args '--image-gc-high-threshold=50 --image-gc-low-threshold=40  --minimum-container-ttl-duration=0s'