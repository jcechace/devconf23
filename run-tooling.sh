source env.sh

kubectl exec -it pods/tooling -n $NAMESPACE -- /bin/bash 