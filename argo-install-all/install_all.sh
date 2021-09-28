#!/bin/bash -x 
#------------------
#Argo Event 
#------------------
#------Create NameSpace
kubectl create namespace argo-events
#------Install Argo Events
for all in `ls -1 argo-event-yamls/*`;do
	kubectl -n argo-events apply -f $all
done
#==================================
echo "Argo Event Install Done"
#--------------
#ARGO CD
#=========
#kubectl create namespace argocd
#kubectl apply -n argocd -f argocd-yamls/
#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
#echo "User : admin, Password:"
#kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
#echo "Argo CD Install Done"
#sleep 10
#-----
#Argo Workflow
#---------
kubectl create namespace argo
kubectl apply -n argo -f argo-wf-yamls/
#kubectl patch svc argo-server -n argo -p '{"spec": {"type": "NodePort"}}'
