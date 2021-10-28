# Kubernetes
```
## repo created in github / gitlab and solved below problem option
1. Created a kubernetes deployment, svc, hpa, pdb service account in AKS kubernetes cluster
2. Deployment needs a secret with name API_KEY
3. Mount this secret in deployment
. API_KEY should be a environment variables within the container when container starts inside a pod
5. API_KEY env variable is not used yet in app, but we want to see the approach
Acceptance criteria
You must provide your code in full with kubernetes manifests or pipelines or scripts
You must use either public cloud(AWS, GCP, Azure) or Minikube to run the above manifests file
You do not need to provide access to the cluster in public cloud, only the code
Your code is clean and readable
You must document any steps that are not automated in the README.md
You must have dedicated service account for deployment
You must have NodePort Type of service for application
You must have Minimum 2 pods always up and running
You must have only 1 pod unavailable during Rolling Update of Deployment
Assumptions
1. Can use any open-source tools/language to solve problem
2. Create extra code if needed like infra(terraform, scripts) etc in same repo
3. Choose simple applications from internet e.g. nginx, httpd
Bonus
1. Deployment container is scanned before getting deployed. If severity is high, pipeline should fail
2. Container in Pod, should not be running as root
3. Provide any code that you required to accomplish this task
. You must document any steps that are not automated in the README.md

```
## Step-01: Introduction
- Created a kubernetes deployment, svc, hpa, pdb service account in kubernetes cluster
- Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. 
- Storing confidential information in a Secret is safer and more flexible than putting it directly in a Pod definition or in a container image. 

## Step-02: Create Secret for MySQL DB Password
### 
```
# Mac
echo -n 'dbpassword11' | base64

# URL: https://www.base64encode.org
```
### Create Kubernetes Secrets manifest
```yml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-db-password
#type: Opaque means that from kubernetes's point of view the contents of this Secret is unstructured.
#It can contain arbitrary key-value pairs. 
type: Opaque
data:
  # Output of echo -n 'Redhat1449' | base64
  db-password: ZGJwYXNzd29yZDEx
```
## Step-03: Update secret in MySQL Deployment for DB Password
```yml
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-db-password
                  key: db-password
```

## Step-04: Update secret in UWA Deployment
- UMS means User Management Microservice
```yml
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-db-password
                  key: db-password
```

## Step-05: Create & Test
```
# Create All Objects
kubectl apply -f kube-manifests/

# List Pods
kubectl get pods

# Get Public IP of Application
kubectl get svc

# Access Application
http://<External-IP-from-get-service-output>
Username: admin101
Password: password101
```

## Step-06: Clean-Up
- Delete all k8s objects created as part of this section
```
# Delete All
kubectl delete -f kube-manifests/

# List Pods
kubectl get pods

# Verify sc, pvc, pv
kubectl get sc,pvc,pv
```
