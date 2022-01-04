#Kubectl create namespace

kubectl create namespace monitoring 

#InfluxDB secret
kubectl create secret generic influxdb-creds --from-literal=INFLUXDB_DATABASE=local_monitoring --from-literal=INFLUXDB_USERNAME=root --from-literal=INFLUXDB_PASSWORD=root1234 --from-literal=INFLUXDB_HOST=influxdb

#InfluxDB build PVC and Deploy
kubectl -n monitoring apply -f ./InfuxDB-pvc.yml,./InfuxDB-deploy.yml

#InfluxDB build Secrets, Config, Deploy
kubectl -n monitoring apply -f ./Telegraf-secret.yml,./Telegraf-config.yml,./Telegraf-deploy.yml

#InfluxDB service
kubectl expose deployment influxdb --port=8086 --target-port=8086 --protocol=TCP --type=ClusterIP

#Telegraf service
kubectl expose deployment telegraf --port=8125 --target-port=8125 --protocol=UDP --type=NodePort

#Grafana secret
kubectl create secret generic grafana-creds --from-literal=GF_SECURITY_ADMIN_USER=admin --from-literal=GF_SECURITY_ADMIN_PASSWORD=admin1234

#Grafana build Deploy
kubectl -n monitoring apply ./Grafana-deploy.yml

#Grafana service
kubectl expose deployment grafana --type=LoadBalancer --port=3000 --target-port=3000 --protocol=TCP