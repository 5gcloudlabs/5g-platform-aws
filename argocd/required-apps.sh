#!/bin/bash

aws eks update-kubeconfig --region eu-central-1 --name cloud-5g-eks

kubectl apply -f required-apps.yml
