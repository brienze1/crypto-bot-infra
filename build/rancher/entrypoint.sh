#!/bin/bash

# RANCHER 1
echo "########### Waiting rancher to become healthy ###########"
until curl http://rancher -s; do
  sleep 5
done
echo "########### Rancher is up ###########"
sleep 20

echo "########### Getting token for rancher ###########"
TOKEN=$(curl -k -s 'https://rancher/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary '{"username":"admin","password":"password","ttl":0}' | jq -r .token)
sleep 5

echo "########### Authenticating rancher ###########"
rancher login https://rancher/v3 --token "$TOKEN" --skip-verify
sleep 5

echo "########### Deploying local path storage ###########"
rancher kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml --server https://rancher
rancher kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' --server https://rancher

echo "########### Deploying metrics server ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/metrics-server --server https://rancher
rancher kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous --server https://rancher

echo "########### Deploying kube-state-metrics server ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/kube-state-metrics --server https://rancher

echo "########### Deploying prometheus server ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/prometheus --server https://rancher

echo "########### Deploying grafana server ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/grafana --server https://rancher

echo "########### Deploying accounts db on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-accounts-database --server https://rancher

echo "########### Deploying wallets db on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-wallets-database --server https://rancher

echo "########### Deploying redis on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-redis --server https://rancher

echo "########### Deploying accounts api on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-accounts --server https://rancher

echo "########### Deploying wallets api on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-wallets --server https://rancher

echo "########### Deploying simulations api on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-simulations --server https://rancher
