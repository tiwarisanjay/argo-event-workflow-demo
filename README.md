# argo-event-workflow-demo
```
This demo is to create a sample CICD using Argo Event and Argo Demo.
We are using terraform to create one namespace. 
PV-PVC used to save terraform state file at local backend. 
Secret are used to save your github token [ For Example as github webhook. (WIP) ]
```
## Pre-requisites 
- Install ArgoEvent and Argo Workflow before starting. 
    - Install using [repo](https://github.com/tiwarisanjay/argo-install-all)
    - Or Install Manually one by one using 
        - [Argo Events](https://argoproj.github.io/argo-events/installation/)
        - [Argo Workflow](https://argoproj.github.io/argo-workflows/installation/)
- There are two ways your can Open UI By Port forwarding or by NodePort(Minikube, Docker Desktop Kubernates)
    - Port Forwarding : 
        - `kubectl port-forward svc/argo-server 2746:2746 -n argo &`
    - Node Port:
        - `kubectl patch svc argo-server -n argo -p '{"spec": {"type": "NodePort"}}'`
- After Open UI with 
    - If port forwarded :
        `https://localhost:2746`
    - If Node Port 
        `https://localhost:<NodePort>`
- Get the Token for login and paste it in Token Area and login to UI. 
    ```
    ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
    echo $ARGO_TOKEN
    ```
- Run Script for pre-requisites 
``` bash
cd prerequisite 
./createrest.sh 
```
- Script will be creating 
    - pv and pvc for local backend 
    - secret for github 
    - namespace for workflow 
    - service account for workflow 
    - role and role binding for workflow service account 


# We have Multiple demos. 
## StandAlone Workflow
## Argo Workflow trigger via webhook of Argo Event 
## Argo Workflow using Webhook template triggered via webhook of argo events