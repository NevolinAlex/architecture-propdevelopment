#!/bin/bash

NAMESPACE="prop-development"
CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

for USER in kuzya-devops vasya-developer kolya-ib; do

  # Генерация ключа и CSR
  openssl genrsa -out $USER.key 2048
  openssl req -new -key $USER.key -out $USER.csr -subj "/CN=$USER/O=$NAMESPACE"

  # Подписываем сертификат через Kubernetes CSR
  cat <<CSR | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  request: $(base64 < $USER.csr | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
CSR

  kubectl certificate approve $USER

  # Забираем подписанный сертификат
  kubectl get csr $USER -o jsonpath='{.status.certificate}' | base64 --decode > $USER.crt

  # Создаём kubeconfig для пользователя
  kubectl config set-cluster $CLUSTER --server=$SERVER \
    --certificate-authority=/etc/kubernetes/pki/ca.crt \
    --embed-certs=true \
    --kubeconfig=$USER.kubeconfig

  kubectl config set-credentials $USER \
    --client-certificate=$USER.crt \
    --client-key=$USER.key \
    --embed-certs=true \
    --kubeconfig=$USER.kubeconfig

  kubectl config set-context $USER \
    --cluster=$CLUSTER \
    --user=$USER \
    --namespace=$NAMESPACE \
    --kubeconfig=$USER.kubeconfig

  kubectl config use-context $USER --kubeconfig=$USER.kubeconfig

done
