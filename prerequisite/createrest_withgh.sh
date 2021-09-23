#!/bin/bash
for all in `ls -1 rest_yaml/*`;do
	kubectl apply -f $all
done

echo "Enter your GitHub Token :: "
read GITHUB_SECRET
if [ -z ${GITHUB_SECRET} ];then
    echo "No GitHub Secret Provided. GitHub Webhook will not work."
else 
    echo "Creating Secret for Github"
    kubectl create secret generic github-access --from-literal=token=${GITHUB_SECRET}
fi 
if [ ! -f ${HOME}/.kube/config  ];then 

    echo "Kube Context file not present at ${HOME}/.kube/config . terraform will fail to create resources."
else
    echo "Creating Config Map for context. Not recommended for production. "
    kubectl create configmap kube-context -n workflows --from-file=${HOME}/.kube/config 
fi 

