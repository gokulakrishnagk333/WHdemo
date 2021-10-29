# Kubernetes
```
**repo created in github / gitlab and solved below problem option**
1. Created a kubernetes Java Application with Mysql DB deployment, svc, hpa, pdb service account in AKS kubernetes cluster
2. Mysql Statefulset deployment needs a secret with name API_KEY
3. Mounted this secret.
4. API_KEY is refered as mysqldbpassword in Mysql environment variables within the container when container starts inside a pod
5. API_KEY env variable is not used yet in app, once the Mysql pod created it get the mysql db password from secret

**Acceptance criteria**
- Provided entire code in full with kubernetes manifests, pipelines, scripts.
- Deployed in Azure Public cloud.
- Also provided rancher access for 1 one day to check deployment and also multi-cloud k8's cluster management.
- I hope entire code is clean and readable
- I have documented all steps that are automated and not automated in the README.md
- Created dedicated service account for deployment
- I have NodePort Type of service for application
- Allocated minimum 2 pods always up and running
- Allocated only 1 pod unavailable during Rolling Update of Deployment

**Assumptions**
1. Can use any open-source tools/language to solve problem
   - Used Gitlab for store code and pipeline
   - Used Trivy for container scanning
   - Custom gitlab-runner installed in centos running GCP
      - Terraform installed
      - Azure CLI for login to azure
      - Trivy installed
      - Docker installed
      - Kubectl service installed 
2. Create extra code if needed like infra(terraform, scripts) etc in same repo
   - Created AKS cluster using terraform script add in same repo
3. Choose simple applications from internet e.g. nginx, httpd
   - Used Java User Management Apllication with Mysql D
Bonus
1. Deployment container is scanned before getting deployed. If severity is high, pipeline should fail
2. Container in Pod, should not be running as root
3. Provide any code that you required to accomplish this task
. You must document any steps that are not automated in the README.md
```
## Pre-requisites
- Created AKS cluster using terraform script add in same repo
- GitLab Account
- Gitlab Runner
  - Trivy
  - Kubectl
  - Azure Cli
  - Docker
  - Java
  - Maven
  - Created Kubemanifests files

```
## Step-01: Introduction
- Created a kubernetes deployment, svc, hpa, pdb service account in kubernetes cluster
- Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. 
- Storing confidential information in a Secret is safer and more flexible than putting it directly in a Pod definition or in a container image. 

## Step-02: Created Secret for MySQL environment DB Password 
### 
```
dbpassword11'

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
