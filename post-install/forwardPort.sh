#!/bin/bash

echo "Forwarding Ports  "
kubectl port-forward svc/argo-server 2746:2746 -n argo &
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
