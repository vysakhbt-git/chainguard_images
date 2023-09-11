#!/usr/bin/env bash

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80 &
PF_PID=$!

kubectl apply -f $SCRIPT_DIR/httpbin.yaml

kubectl wait --for=condition=ready pod -l app=httpbin

for i in {1..5}; do
    set -o pipefail
    curl -I localhost:8080/status/202 -HHost:httpbin.test.ingress | grep ACCEPTED \
        && break
    sleep 5
done

kill $PF_PID | true
