#!/bin/bash
echo "=========================================="
echo "Load Test Report - $(date)"
echo "=========================================="
echo ""
echo "1. Node Usage:"
kubectl top nodes
echo ""
echo "2. Pod Usage:"
kubectl top pods -n openedx
echo ""
echo "3. HPA Status:"
kubectl get hpa -n openedx
echo ""
echo "4. Pod Count:"
kubectl get pods -n openedx | grep -E "NAME|lms|cms"
echo ""
echo "5. HPA Events:"
kubectl describe hpa lms-hpa -n openedx | grep -A 3 "Events"
echo ""
echo "=========================================="
