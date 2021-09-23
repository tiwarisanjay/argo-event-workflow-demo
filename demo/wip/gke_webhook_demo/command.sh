curl -d '{"message":"ok"}' -H "Content-Type: application/json" -X POST http://localhost:31236/devops-toolkit
#Patch Controller to work the workflow
kubectl patch configmap workflow-controller-configmap --patch '{"data":{"containerRuntimeExecutor":"k8sapi"}}' --namespace=argo
