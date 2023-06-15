source env.sh

kubectl exec -it deployments/mongo -n $NAMESPACE -- mongosh 'mongodb://debezium:dbz@mongo:27017/inventory?authSource=admin&replicaSet=rs0'