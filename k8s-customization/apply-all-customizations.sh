#!/bin/bash
set -e
echo "=========================================="
echo "Applying All K8s Customizations"
echo "=========================================="

# 1. Resource Requests - LMS & CMS
echo "1. Patching resource requests..."
for deploy in lms cms; do
  kubectl patch deployment $deploy -n openedx --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/resources","value":{"requests":{"cpu":"250m","memory":"512Mi"},"limits":{"cpu":"1000m","memory":"2Gi"}}}]' 2>/dev/null || true
done

for deploy in lms-worker cms-worker; do
  kubectl patch deployment $deploy -n openedx --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/resources","value":{"requests":{"cpu":"200m","memory":"512Mi"},"limits":{"cpu":"800m","memory":"1Gi"}}}]' 2>/dev/null || true
done
echo "Resource requests applied"

# 2. HPA
echo "2. Applying HPAs..."
kubectl apply -f - << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: lms-hpa
  namespace: openedx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lms
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cms-hpa
  namespace: openedx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cms
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: lms-worker-hpa
  namespace: openedx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lms-worker
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 75
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cms-worker-hpa
  namespace: openedx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cms-worker
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 75
EOF
echo "HPAs applied"

# 3. NGINX Ingress
echo "3. Applying NGINX ingress..."
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: openedx-nginx-ingress
  namespace: openedx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "250m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/upstream-vhost: "$host"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - lms.alrafi.org
        - studio.alrafi.org
        - apps.lms.alrafi.org
      secretName: openedx-tls-secret
  rules:
    - host: lms.alrafi.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: lms
                port:
                  number: 8000
    - host: studio.alrafi.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: cms
                port:
                  number: 8000
    - host: apps.lms.alrafi.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: mfe
                port:
                  number: 8002
EOF
echo "NGINX ingress applied"

# 4. AWS ALB Ingress
echo "4. Applying AWS ALB ingress..."
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: openedx-aws-alb
  namespace: openedx
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-2:266735809739:certificate/7c36cd4a-9619-482e-8b09-bae73208d51c,arn:aws:acm:us-east-2:266735809739:certificate/9bd6b6c9-3432-490d-9d1b-458cf606b5df
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    alb.ingress.kubernetes.io/healthcheck-port: "traffic-port"
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
    alb.ingress.kubernetes.io/success-codes: "200-399"
spec:
  ingressClassName: alb
  rules:
    - host: lms.alrafi.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-proxy-ingress-nginx-controller
                port:
                  number: 443
    - host: studio.alrafi.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-proxy-ingress-nginx-controller
                port:
                  number: 443
    - host: apps.lms.alrafi.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-proxy-ingress-nginx-controller
                port:
                  number: 443
EOF
echo "AWS ALB ingress applied"

# 5. NGINX ConfigMap
echo "5. Applying NGINX ConfigMap..."
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-proxy-ingress-nginx-controller
  namespace: openedx
data:
  allow-snippet-annotations: "true"
  use-http2: "true"
  use-forwarded-headers: "true"
  compute-full-forwarded-for: "true"
  use-proxy-protocol: "false"
  ssl-protocols: "TLSv1.2 TLSv1.3"
  ssl-prefer-server-ciphers: "true"
  proxy-body-size: "250m"
  proxy-read-timeout: "300"
  proxy-send-timeout: "300"
  proxy-connect-timeout: "60"
  use-gzip: "true"
EOF
echo "NGINX ConfigMap applied"

# 6. Cluster Issuer
echo "6. Applying Cluster Issuer..."
kubectl apply -f - << 'EOF'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: contact@alrafi.org
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
echo "Cluster Issuer applied"

# 7. Persistent Volume Claims
echo "7. Creating LMS and CMS storage PVCs..."
cat > ~/openedx-storage.yaml << 'EOF'
# LMS Media Storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lms-media
  namespace: openedx
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 10Gi
---
# CMS Media Storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cms-media
  namespace: openedx
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 10Gi
EOF

kubectl apply -f ~/openedx-storage.yaml
echo "PVCs applied"

# 8. Patch LMS and CMS Deployments with volumes
echo "8. Patching LMS and CMS deployments to mount PVCs..."
# Patch LMS
kubectl patch deployment lms -n openedx --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "lms-media",
      "persistentVolumeClaim": {
        "claimName": "lms-media"
      }
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts/-",
    "value": {
      "name": "lms-media",
      "mountPath": "/openedx/media"
    }
  }
]'

# Patch CMS
kubectl patch deployment cms -n openedx --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "cms-media",
      "persistentVolumeClaim": {
        "claimName": "cms-media"
      }
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts/-",
    "value": {
      "name": "cms-media",
      "mountPath": "/openedx/media"
    }
  }
]'

echo "LMS and CMS deployments patched with PVCs"

# 9. Update security context for LMS & CMS
echo "9. Updating security context for LMS and CMS..."
# LMS
kubectl patch deployment lms -n openedx --patch '{"spec": {"template": {"spec": {"securityContext": {"fsGroup": 1000}}}}}'

# CMS
kubectl patch deployment cms -n openedx --patch '{"spec": {"template": {"spec": {"securityContext": {"fsGroup": 1000}}}}}'

echo "LMS and CMS deployments patched with PVCs and security context"

echo ""
echo "=========================================="
echo "All customizations applied!"
echo "=========================================="
echo ""
echo "Status:"
kubectl get pvc -n openedx
kubectl get hpa -n openedx
kubectl get ingress -n openedx
kubectl get pods -n openedx
kubectl get certificate -n openedx
