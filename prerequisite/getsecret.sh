#!/bin/bash

SECRET=$(kubectl -n argo get sa argo-server -o=jsonpath='{.secrets[0].name}')
ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
echo $ARGO_TOKEN

echo "ARGO CD Password "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo " "

