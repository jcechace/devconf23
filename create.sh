source env.sh

echo "### DEVCONF DEMO ENVIRONMENT ###"
# Create cluster
echo ">>> Creating Cluster"
kind create cluster --name $CLUSTER
kubectl cluster-info --context kind-$CLUSTER

# Create namespace
echo ">>> Creating namespace"
kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace $NAMESPACE

# Load Images
echo ">>> Pulling images"
docker pull quay.io/debezium/example-mongodb:latest
docker pull quay.io/debezium/operator:devconf
docker pull quay.io/strimzi/operator:0.35.1
docker pull quay.io/strimzi/kafka:0.35.1-kafka-3.4.0 
docker pull quay.io/debezium/server:2.3
docker pull quay.io/debezium/tooling:latest


echo ">>> Loading images"
kind load docker-image quay.io/debezium/example-mongodb:latest --name $CLUSTER
kind load docker-image quay.io/debezium/operator:devconf --name $CLUSTER
kind load docker-image quay.io/debezium/server:2.3 --name $CLUSTER
kind load docker-image quay.io/strimzi/kafka:0.35.1-kafka-3.4.0 --name $CLUSTER
kind load docker-image quay.io/strimzi/operator:0.35.1 --name $CLUSTER
kind load docker-image quay.io/debezium/tooling:latest --name $CLUSTER

# Deploy Operators
echo ">>> Deploying Operators"
kubectl create -f infra/operators/strimzi.yml -n $NAMESPACE
kubectl create -f infra/operators/debezium.yml -n $NAMESPACE

# Wait for operators
echo ">>> Waiting for operators"
kubectl wait --for=condition=Available deployments/strimzi-cluster-operator  --timeout=240s -n $NAMESPACE
echo ">>> Strimzi operator ready"
kubectl wait --for=condition=Available deployments/debezium-operator  --timeout=240s -n $NAMESPACE
echo ">>> Debezium operator ready"


# Deploy other infra
echo ">>> Deploying MongoDB"
kubectl create -f infra/mongo.yml -n $NAMESPACE
echo ">>> Deploying tools"
kubectl create -f infra/tooling.yml -n $NAMESPACE
echo ">>> Deploying kafka"
kubectl apply -f infra/kafka.yml -n $NAMESPACE


# Wait for other resources
echo ">>> Waiting for infrastructure resources"
## Mongo
echo ">>> Waiting for MongoDB"
kubectl wait --for=condition=Available deployments/mongo --timeout=240s -n $NAMESPACE
echo ">>> Initializing MongoDB Replica Set"
kubectl exec -t deployments/mongo -n $NAMESPACE  -- bash -c '/usr/local/bin/init-inventory.sh -h mongo' 
echo ">>> MongoDB ready"
## Tooling
echo ">>> Waiting for tooling"
kubectl wait --for=condition=Ready pods/tooling --timeout=240s -n $NAMESPACE
echo ">>> Tooling ready"
## Kafka
echo ">>> Waiting  for Kafka"
kubectl wait --for=condition=Ready kafkas/dbz-kafka --timeout=240s -n $NAMESPACE
echo ">>> Kafka ready"