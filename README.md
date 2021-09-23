# argo-event-workflow-demo
# Using MacBook & DockerDesktop Kubernates. You dont need anything but to run following script for everything
- ### Script will Install Argo Event & Argo Workflow and it will run the hello world. #####
- Clone the repo 
```
 git clone https://github.com/tiwarisanjay/argo-event-workflow-demo.git

```
- Run Script : 
```
cd argo-event-workflow-demo
./end_to_end.sh 
```
# Not using Docker Desktop and MacBook 
- ### Most of the Stuff were tested on Mac or Ubuntu. #####
- ### NOTE : You might have to find your own way of doing things with Windows for some of the scripts #####

```
This demo is to create a sample CICD using Argo Event and Argo Demo.
We are using terraform to create one namespace. 
PV-PVC used to save terraform state file at local backend. 
Secret are used to save your github token [ For Example as github webhook. (WIP) ]
```
## Pre-requisites 
- Install ArgoEvent and Argo Workflow before starting. 
    - Install using [repo](https://github.com/tiwarisanjay/argo-install-all)
    - Install by running a script : 
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
- Services After Install : 
    - Argo WOrkflow
        ```
            kubectl get all -n argo
                NAME                                       READY   STATUS    RESTARTS   AGE
                pod/argo-server-d8ff9d9c8-tw4s4            0/1     Running   0          8s
                pod/workflow-controller-67dcb4d8b7-hbdpr   1/1     Running   0          8s

                NAME                                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
                service/argo-server                   ClusterIP   10.107.198.95   <none>        2746/TCP   8s
                service/workflow-controller-metrics   ClusterIP   10.111.245.42   <none>        9090/TCP   8s

                NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
                deployment.apps/argo-server           0/1     1            0           8s
                deployment.apps/workflow-controller   1/1     1            1           8s

                NAME                                             DESIRED   CURRENT   READY   AGE
                replicaset.apps/argo-server-d8ff9d9c8            1         1         0       8s
                replicaset.apps/workflow-controller-67dcb4d8b7   1         1         1       8s
        ```
    - Argo Events 
        ```
        kubectl get all -n argo-events
            NAME                                          READY   STATUS    RESTARTS   AGE
            pod/eventbus-controller-7494ccf7c7-mc7hw      1/1     Running   0          60s
            pod/eventbus-default-stan-0                   2/2     Running   0          51s
            pod/eventbus-default-stan-1                   2/2     Running   0          48s
            pod/eventbus-default-stan-2                   2/2     Running   0          45s
            pod/events-webhook-77c6c47dd6-kmlrx           1/1     Running   0          59s
            pod/eventsource-controller-5665446686-xfr7k   1/1     Running   0          60s
            pod/sensor-controller-6cf84c4564-l7xwk        1/1     Running   0          60s

            NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
            service/eventbus-default-stan-svc   ClusterIP   None             <none>        4222/TCP,6222/TCP,8222/TCP   51s
            service/events-webhook              ClusterIP   10.109.159.244   <none>        443/TCP                      59s

            NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
            deployment.apps/eventbus-controller      1/1     1            1           60s
            deployment.apps/events-webhook           1/1     1            1           59s
            deployment.apps/eventsource-controller   1/1     1            1           60s
            deployment.apps/sensor-controller        1/1     1            1           60s

            NAME                                                DESIRED   CURRENT   READY   AGE
            replicaset.apps/eventbus-controller-7494ccf7c7      1         1         1       60s
            replicaset.apps/events-webhook-77c6c47dd6           1         1         1       59s
            replicaset.apps/eventsource-controller-5665446686   1         1         1       60s
            replicaset.apps/sensor-controller-6cf84c4564        1         1         1       60s

            NAME                                     READY   AGE
            statefulset.apps/eventbus-default-stan   3/3     51s
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



# Hello World Workflow
- To Create Hello World Demo 
```bash 
#Create Event 
kubectl apply -f demo/event_source/event-source.yaml
#Check for Deployemnt "event-source-eventsource-" , Namespce : argo-events
# "Patch Servcie to NodePort "
kubectl patch svc event-source-eventsource-svc -n argo-events -p '{"spec": {"type": "NodePort"}}'
#=======================================
#Create Sensor with workflow
kubectl apply -f demo/hello_world_webhook/hello-world-sensor.yaml
#Validate if deployment is ready 
#Name will be like :: hello-world-webhook-sensor-* , NameSpace:: argo-events

# "Create the Workflow by hitting URL...."
PORT=`kubectl get svc event-source-eventsource-svc -n argo-events -o=jsonpath='{.spec.ports[0].nodePort}'`
curl -d '{"message":"Bhiya Ram!!"}' -H "Content-Type: application/json" -X POST http://localhost:${PORT}/hello-world 

# "List All the workflows..."
argo list -n workflows 

# "Run following command to get status of workflow listed..."
#  argo get <workflow> -n workflows
#  Ex : argo get hello-world-prmcz -n workflows"
```
<!-- ## Argo Workflow trigger via webhook of Argo Event 
## Argo Workflow using Webhook template triggered via webhook of argo events -->
## Login to Argo Workflow UI to check the workflow 
- Get the Token for login and paste it in Token Area and login to UI. 
    ```
    SECRET=$(kubectl -n argo get sa argo-server -o=jsonpath='{.secrets[0].name}')
    ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
    echo $ARGO_TOKEN
    ```
- Run following command to get UI URL if you are running with NodePort : 
```
WHPORT=`kubectl get svc argo-server -n argo -o=jsonpath='{.spec.ports[0].nodePort}'`
echo "URL :: https://localhost:${WHPORT}"
```
- Use Token for Login : 
![Alt text](images/SS1.png?raw=true "Login Page")
- Check Hello World Workflow 
![Alt text](images/SS2.png?raw=true "After Login")