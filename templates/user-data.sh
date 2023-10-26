#!/bin/bash
set -o xtrace
VERSION=${eks_cluster_client_version}
curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-${VERSION}-linux-amd64.tar.gz --output crictl-${VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

/etc/eks/bootstrap.sh ${eks_cluster_name} ${bootstrap_arguments} --container-runtime containerd --kubelet-extra-args '--image-gc-high-threshold=50 --image-gc-low-threshold=40  --minimum-container-ttl-duration=0s'