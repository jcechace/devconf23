source env.sh

# Deploy debezium
echo "### Deploying Debezium ###"
kubectl create -f deploy/debezium.yml -n $NAMESPACE
echo ">>> Waiting for debezium server"
kubectl wait --for=condition=Ready 'debeziumservers/devconf-debezium' --timeout=120s -n $NAMESPACE
echo ">>> Debezium ready"