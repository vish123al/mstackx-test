# mstackx-test
## pre-requisites
## 1. Need to to have GCP account and enable k8s engine on google console
## 2. GCP CLI

Q. What was the node size chosen for the Kubernetes nodes? And why?
A. Node count was 3, for enough resources for all the pods on a node

Q. What method was chosen to install the demo application and ingress controller on the cluster, justify the
method used
A. 1. ingress controller directly deployed it from raw.githubusercontent.com with "kubectl aaply -f filename" command
   2. demo application deployed from k8s.io/examples/application/guestbook with "kubectl apply -f filename" command
   
Q. What would be your chosen solution to monitor the application on the cluster and why?
A. used pod autoscaller, it help us to perform load baalncing on application.

Q. What additional components / plugins would you install on the cluster to manage it better?
A. Not sure about it



