#!/bin/bash

mydir=`pwd`

#=================
validateDeployment(){
    findname=$1
    namespace=$2
    deployment=`kubectl get deployment -n ${namespace} | grep "${findname}" | awk '{print $1}'`
    kubectl rollout status -n ${namespace} deploy/${deployment}
    if [ $? -gt 0 ];then
        echo "Deployment ${deployment} in namespace $namespace failed please check."
        exit 1
    fi
}
echo "Download ArgoCLI if not present"
argo version
if [ $? -gt 0 ];then
    # Download the binary
    curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.1.12/argo-darwin-amd64.gz
    # Unzip
    gunzip argo-darwin-amd64.gz
    # Make binary executable
    chmod +x argo-darwin-amd64
    # Move binary to path
    mv ./argo-darwin-amd64 /usr/local/bin/argo
    # Test installation
    argo version
    [ $? -gt 0 ] && echo "Download Argo CLI for workflow manually and run this script again." && exit 1
fi
#=================
mydir=`pwd`
echo "==========================================================="
echo "Install ArgoEvent,ArgoCD,Argo Workflow"
echo "==========================================================="
cd argo-install-all
./install_all.sh
echo "Validate for Workflow Controller Deployement....."
validateDeployment workflow-controller argo
echo "Validate for eventsource controller Deployment...."
validateDeployment eventsource-controller argo-events
echo "Validate for event bus controller Deployment ..."
validateDeployment eventbus-controller argo-events
echo "Validate for Sensor Controller Deployment..."
validateDeployment sensor-controller argo-events
echo "Validate for Events webhook deployment.."
validateDeployment events-webhook argo-events
echo "==========================================================="
echo "Installation Done for ArgoCD, ArgoEvent and Argo Workflow. We will not use ArgoCD for this Demo."
echo "==========================================================="
echo "==========================================================="
echo "Create Secret with Context, Namespace Workflow, PV and PVC for tf remote"
echo "==========================================================="
cd $mydir
cd prerequisite
./createrest.sh
sleep 5
echo "==========================================================="
echo "Change Argo workflow & ArgoCD svc to NodePort for UI Access "
echo "==========================================================="
echo "Validate if deployment for argo workflow UI is ready...."
cd $mydir
validateDeployment argo-server argo
kubectl patch svc argo-server -n argo -p '{"spec": {"type": "NodePort"}}'

sleep 3
echo "========================"
echo "Create Webhook Event "
echo "========================"

kubectl apply -f demo/event_source/event-source.yaml
echo "Checking if deployemnt is ready..."
validateDeployment "event-source-eventsource-" argo-events
echo "Deployment is ready for event source"
echo "Patch Servcie to NodePort "
kubectl patch svc event-source-eventsource-svc -n argo-events -p '{"spec": {"type": "NodePort"}}'


echo "========================"
echo "Create Sensor with Workflow"
echo "========================"
kubectl apply -f demo/hello_world_webhook/hello-world-sensor.yaml
#Validate if deployment is ready
validateDeployment "hello-world-webhook-sensor-" argo-events

echo "Deployment is ready for sensor with workflow"
echo "============================================================="
echo "Sleeping for 30sec to keep the event/workflow ready........"
echo "============================================================="
sleep 30
echo "Create the Workflow by hitting URL...."
PORT=`kubectl get svc event-source-eventsource-svc -n argo-events -o=jsonpath='{.spec.ports[0].nodePort}'`
echo curl -d '{"message":"Bhiya Ram!!"}' -H "Content-Type: application/json" -X POST http://localhost:${PORT}/hello-world
curl -d '{"message":"Bhiya Ram!!"}' -H "Content-Type: application/json" -X POST http://localhost:${PORT}/hello-world
echo "List All the workflows..."
argo list -n workflows
echo "Run following command to get status of workflow listed..."
echo "argo get <workflow> -n workflows"
echo "Ex : argo get hello-world-prmcz -n workflows"
WHPORT=`kubectl get svc argo-server -n argo -o=jsonpath='{.spec.ports[0].nodePort}'`
echo "Open Link https://localhost:${WHPORT}"
echo "Use Following Token in Token area for authentication...."
echo "=================================="
SECRET=$(kubectl -n argo get sa argo-server -o=jsonpath='{.secrets[0].name}')
ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
echo $ARGO_TOKEN
echo "========================================================"
