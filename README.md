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
                NAME                                      READY   STATUS    RESTARTS   AGE
                pod/argo-server-5d58f6585d-sz59s          1/1     Running   3          48m
                pod/minio-77d6796f8d-8kzw7                1/1     Running   0          48m
                pod/postgres-546d9d68b-fk78m              1/1     Running   0          48m
                pod/workflow-controller-558db44f7-hvfrw   1/1     Running   3          48m

                NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
                service/argo-server                   NodePort    10.109.246.11    <none>        2746:30736/TCP   48m
                service/minio                         ClusterIP   10.102.155.241   <none>        9000/TCP         48m
                service/postgres                      ClusterIP   10.105.198.98    <none>        5432/TCP         48m
                service/workflow-controller-metrics   ClusterIP   10.107.181.197   <none>        9090/TCP         48m

                NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
                deployment.apps/argo-server           1/1     1            1           48m
                deployment.apps/minio                 1/1     1            1           48m
                deployment.apps/postgres              1/1     1            1           48m
                deployment.apps/workflow-controller   1/1     1            1           48m

                NAME                                            DESIRED   CURRENT   READY   AGE
                replicaset.apps/argo-server-5d58f6585d          1         1         1       48m
                replicaset.apps/minio-77d6796f8d                1         1         1       48m
                replicaset.apps/postgres-546d9d68b              1         1         1       48m
                replicaset.apps/workflow-controller-558db44f7   1         1         1       48m
        ```
    - Argo Events 
        ```
        kubectl get all -n argo-events
            NAME                                          READY   STATUS    RESTARTS   AGE
            pod/eventbus-controller-7494ccf7c7-9gz76      1/1     Running   0          49m
            pod/eventbus-default-stan-0                   2/2     Running   0          48m
            pod/eventbus-default-stan-1                   2/2     Running   0          48m
            pod/eventbus-default-stan-2                   2/2     Running   0          48m
            pod/events-webhook-77c6c47dd6-kv5bd           1/1     Running   0          49m
            pod/eventsource-controller-5665446686-nm6sz   1/1     Running   0          49m
            pod/sensor-controller-6cf84c4564-ln5hf        1/1     Running   0          49m

            NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
            service/eventbus-default-stan-svc   ClusterIP   None            <none>        4222/TCP,6222/TCP,8222/TCP   48m
            service/events-webhook              ClusterIP   10.111.194.79   <none>        443/TCP                      49m

            NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
            deployment.apps/eventbus-controller      1/1     1            1           49m
            deployment.apps/events-webhook           1/1     1            1           49m
            deployment.apps/eventsource-controller   1/1     1            1           49m
            deployment.apps/sensor-controller        1/1     1            1           49m

            NAME                                                DESIRED   CURRENT   READY   AGE
            replicaset.apps/eventbus-controller-7494ccf7c7      1         1         1       49m
            replicaset.apps/events-webhook-77c6c47dd6           1         1         1       49m
            replicaset.apps/eventsource-controller-5665446686   1         1         1       49m
            replicaset.apps/sensor-controller-6cf84c4564        1         1         1       49m

            NAME                                     READY   AGE
            statefulset.apps/eventbus-default-stan   3/3     48m
        ```
    - Argo CD
        ```
        kubectl get all -n argocd
            NAME                                      READY   STATUS    RESTARTS   AGE
            pod/argocd-application-controller-0       1/1     Running   0          50m
            pod/argocd-dex-server-5dc4df4967-6qpqc    1/1     Running   0          50m
            pod/argocd-redis-5b6967fdfc-j67v2         1/1     Running   0          50m
            pod/argocd-repo-server-5f9b5d9584-7h487   1/1     Running   0          50m
            pod/argocd-server-86dcc9f88f-mm8w2        1/1     Running   0          50m

            NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
            service/argocd-dex-server       ClusterIP   10.103.98.154    <none>        5556/TCP,5557/TCP,5558/TCP   50m
            service/argocd-metrics          ClusterIP   10.99.141.227    <none>        8082/TCP                     50m
            service/argocd-redis            ClusterIP   10.104.80.245    <none>        6379/TCP                     50m
            service/argocd-repo-server      ClusterIP   10.101.96.22     <none>        8081/TCP,8084/TCP            50m
            service/argocd-server           NodePort    10.104.138.12    <none>        80:32668/TCP,443:32751/TCP   50m
            service/argocd-server-metrics   ClusterIP   10.106.102.160   <none>        8083/TCP                     50m

            NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
            deployment.apps/argocd-dex-server    1/1     1            1           50m
            deployment.apps/argocd-redis         1/1     1            1           50m
            deployment.apps/argocd-repo-server   1/1     1            1           50m
            deployment.apps/argocd-server        1/1     1            1           50m

            NAME                                            DESIRED   CURRENT   READY   AGE
            replicaset.apps/argocd-dex-server-5dc4df4967    1         1         1       50m
            replicaset.apps/argocd-redis-5b6967fdfc         1         1         1       50m
            replicaset.apps/argocd-repo-server-5f9b5d9584   1         1         1       50m
            replicaset.apps/argocd-server-86dcc9f88f        1         1         1       50m

            NAME                                             READY   AGE
            statefulset.apps/argocd-application-controller   1/1     50m

        ```
- Get the Token for login and paste it in Token Area and login to UI. 
    ```
    SECRET=$(kubectl -n argo get sa argo-server -o=jsonpath='{.secrets[0].name}')
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