# 1. Create namespace
kubectl create namespace load-testing

# 2. Create Locust test script
cat > ~/locustfile.py << 'PYEOF'
from locust import HttpUser, task, between

class OpenEdXStudent(HttpUser):
    """Simulates students browsing LMS"""
    wait_time = between(2, 5)

    @task(5)
    def homepage(self):
        self.client.get("/", name="LMS Homepage")

    @task(3)
    def courses(self):
        self.client.get("/courses", name="Course Catalog")

    @task(2)
    def dashboard(self):
        self.client.get("/dashboard", name="Dashboard")

    @task(2)
    def heartbeat(self):
        self.client.get("/heartbeat", name="Heartbeat")

    @task(1)
    def login_page(self):
        self.client.get("/login", name="Login Page")

    @task(1)
    def register_page(self):
        self.client.get("/register", name="Register Page")
PYEOF

# 3. Create ConfigMap
kubectl create configmap locust-script \
  --from-file=locustfile.py=$HOME/locustfile.py \
  -n load-testing

# 4. Deploy Locust (lightweight for t3.large nodes)
cat > ~/locust-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: locust-master
  namespace: load-testing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: locust
      role: master
  template:
    metadata:
      labels:
        app: locust
        role: master
    spec:
      containers:
        - name: locust
          image: locustio/locust:2.29.1
          ports:
            - containerPort: 8089
            - containerPort: 5557
          command: ["locust"]
          args:
            - "--master"
            - "--locustfile=/mnt/locust/locustfile.py"
            - "--host=https://lms.alrafi.org"
          volumeMounts:
            - name: locust-script
              mountPath: /mnt/locust
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              cpu: 200m
              memory: 256Mi
      volumes:
        - name: locust-script
          configMap:
            name: locust-script
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: locust-worker
  namespace: load-testing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: locust
      role: worker
  template:
    metadata:
      labels:
        app: locust
        role: worker
    spec:
      containers:
        - name: locust
          image: locustio/locust:2.29.1
          command: ["locust"]
          args:
            - "--worker"
            - "--master-host=locust-master"
            - "--locustfile=/mnt/locust/locustfile.py"
          volumeMounts:
            - name: locust-script
              mountPath: /mnt/locust
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              cpu: 200m
              memory: 256Mi
      volumes:
        - name: locust-script
          configMap:
            name: locust-script
---
apiVersion: v1
kind: Service
metadata:
  name: locust-master
  namespace: load-testing
spec:
  selector:
    app: locust
    role: master
  ports:
    - name: web
      port: 8089
      targetPort: 8089
    - name: master
      port: 5557
      targetPort: 5557
EOF

kubectl apply -f ~/locust-deployment.yaml

# 5. Wait and check
kubectl wait --for=condition=ready pod -l app=locust -n load-testing --timeout=120s
kubectl get pods -n load-testing

# 6. Access Locust UI
kubectl port-forward svc/locust-master -n load-testing 8089:8089 --address 0.0.0.0 &
