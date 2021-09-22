#!/bin/bash
echo "Install ArgoEvent,ArgoCD,Argo Workflow"
prerequisite/argo-install-all/install_all.sh

echo "==========================================================="
echo "Installation Done for ArgoCD, ArgoEvent and Argo Workflow"
echo "==========================================================="

echo "Create Secret with Context, Namespace Workflow, PV and PVC for tf remote"
prerequisite/createrest.sh

echo "========================"
echo "Change SVC to NodePort"
kubectl patch svc argo-server -n argo -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

sleep 10
echo "========================"
echo "Create Template for Workflow"
echo "========================"
kubectl apply -f demo/wh_demo_vid_template/templates/

echo "========================"
echo "Create Webhook Event "
echo "========================"

kubectl apply -f demo/wh_demo_vid_template/event-source.yaml

echo "Patch Servcie to NodePort "
kubectl patch svc webhook-eventsource-svc -n argo-events -p '{"spec": {"type": "NodePort"}}'


echo "========================"
echo "Create Sensor with Workflow"
echo "========================"

kubectl apply -f demo/wh_demo_vid_template/tf-wf-sensor.yaml

#Hit the Servcie by changing below node port
# curl -d '{"message":"Bhiya Ram!!"}' -H "Content-Type: application/json" -X POST http://localhost:31236/tf-toolkit
