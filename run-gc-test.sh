#!/bin/bash
set -e

echo "Starting Kubernetes GC test with kube-burn..."

# Apply the test
kubectl apply -f gc-test.yaml

# Wait for test completion
echo "Waiting for test to complete..."
kubectl wait --for=condition=Complete test/gc-test --timeout=300s

# Check test results
echo "Test results:"
kubectl describe test gc-test

# Verify cleanup
echo "Verifying garbage collection..."
sleep 10
REMAINING=$(kubectl get configmaps,deployments -l test=gc-collection --no-headers 2>/dev/null | wc -l)
echo "Remaining resources: $REMAINING"

if [ "$REMAINING" -eq 0 ]; then
    echo "✅ GC test passed - all resources cleaned up"
else
    echo "❌ GC test failed - $REMAINING resources remain"
    kubectl get configmaps,deployments -l test=gc-collection
fi

# Cleanup test object
kubectl delete test gc-test