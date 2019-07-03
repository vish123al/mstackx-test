#!/bin/sh

##Create a Kubernetes cluster on GCP
gcloud config project noble-function-185508
gcloud config set compute/zone us-west1-a
gcloud container clusters create my-cluster
gcloud container clusters get-credentials my-cluster

##Install nginx ingress controller on the cluster
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

##Create namespaces called staging and production.
kubectl create ns staging
kubectl create ns production

##Install guest-book application on both namespaces

kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml -n staging
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml -n staging
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml -n staging
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml -n staging
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml -n staging
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml -n staging
kubectl get pods  -n staging
kubectl get svc -n staging


kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml -n production
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml -n production
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml -n production
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml -n production
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml -n production
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml -n production
kubectl get pods  -n production
kubectl get svc -n production

##Expose staging application on hostname staging-guestbook.mstakx.io

cat > stage.yaml <<- "EOF"
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  namespace: staging
  annotations:
     kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: staging-guestbook.mstakx.io
    http:
      paths:
      - path: /
        backend:
          serviceName: frontend
          servicePort: 80
EOF

kubectl apply -f stage.yaml -n staging

cat > prod.yaml <<- "EOF"
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  namespace: production 
  annotations:
     kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: guestbook.mstakx.io
    http:
      paths:
      - path: /
        backend:
          serviceName: frontend
          servicePort: 80
EOF

kubectl apply -f prod.yaml -n production

##Implement a pod autoscaler on both namespaces which will scale frontend pod replicas up and down

kubectl autoscale deploy frontend --min=2 --max=5 --cpu-percent=80 -n staging 
kubectl get hpa

## Write a script which will demonstrate how the pods are scaling up and down by increasing/decreasing load
##manual process



