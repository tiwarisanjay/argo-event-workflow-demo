kubectl patch svc webhook-eventsource-svc -n argo-events -p '{"spec": {"type": "NodePort"}}'
curl -d '{"message":"Bhiya Ram!!"}' -H "Content-Type: application/json" -X POST http://localhost:31236/tf-toolkit

