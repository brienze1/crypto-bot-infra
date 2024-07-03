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

echo "########### Deploying metrics server ###########"
rancher kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --server https://rancher

#TODO fix this
echo "########### Deploying accounts db on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-accounts-database --server https://rancher

echo "########### Deploying wallets db on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-wallets-database --server https://rancher

echo "########### Deploying redis on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-redis --server https://rancher

echo "########### Deploying apis on rancher ###########"
rancher kubectl create -f /init-scripts/rancher-cli/eks/crypto-bot-accounts --server https://rancher
