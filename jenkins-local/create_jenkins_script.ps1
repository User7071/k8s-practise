kubectl create ns jenkins

# create volume
kubectl apply -f ./jenkins.pv.yml 
kubectl get pv

# create volume claim
kubectl apply -n jenkins -f ./jenkins.pvc.yml
kubectl -n jenkins get pvc

# rbac
kubectl apply -n jenkins -f ./jenkins.rbac.yml 

kubectl apply -n jenkins -f ./jenkins.deploy.yml

kubectl -n jenkins get pods

#service
kubectl apply -n jenkins -f ./jenkins.service.yml 