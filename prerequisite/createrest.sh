#!/bin/bash
for all in `ls -1 rest_yaml/*`;do
	kubectl apply -f $all
done
