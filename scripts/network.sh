#!/bin/bash

KUBE_CONFIG="$(mktemp)"
cat > $KUBE_CONFIG <<EOF
apiVersion: v1
kind: Config
clusters:
- name: clustername
  cluster:
    server: ${CLUSTER_ENDPOINT}
    certificate-authority-data: ${CLUSTER_CERT}
contexts:
- name: contextname
  context:
    cluster: clustername
    user: username
current-context: contextname
users:
- name: username
  user:
    token: ${CLUSTER_AUTH_TOKEN}
EOF

# Download kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl

# CNI env configurations
kubectl --kubeconfig "${KUBE_CONFIG}" set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
kubectl --kubeconfig "${KUBE_CONFIG}" set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone

# # Security group for pod env configurations
kubectl --kubeconfig "${KUBE_CONFIG}" set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
kubectl --kubeconfig "${KUBE_CONFIG}" patch daemonset aws-node \
  -n kube-system \
  -p '{"spec": {"template": {"spec": {"initContainers": [{"env":[{"name":"DISABLE_TCP_EARLY_DEMUX","value":"true"}],"name":"aws-vpc-cni-init"}]}}}}'