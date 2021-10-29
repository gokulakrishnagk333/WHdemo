# Understood the given requirement and completed the tasks
```
- Please read entire read.me file
```

## Repo created in github / gitlab and solved below Option 1 problem
```
1. Create a kubernetes deployment, svc, hpa, pdb service account in kubernetes cluster. can be PaaS/Minikube
 - Created a kubernetes Java Application with Mysql DB deployment, svc, hpa, pdb service account in AKS kubernetes cluster
2. Deployment needs a secret with name API_KEY
 - Mysql Statefulset deployment needs a secret with name API-KEY
3. Mount this secret in deployment
 - Mounted this secret.
4. API_KEY should be a environment variables within the container when container starts inside a pod
 - API_KEY is refered as mysqldbpassword in Mysql environment variables within the container when container starts inside a pod
5. API_KEY env variable is not used yet in app, but we want to see the approach
 - API_KEY env variable is not used yet in app, once the Mysql pod created it get the mysql db password from secret
```

## Acceptance criteria
```
1. You must provide your code in full with kubernetes manifests or pipelines or scripts
  - Provided entire code in full with kubernetes manifests, pipelines, scripts.
2. You must use either public cloud(AWS, GCP, Azure) or Minikube to run the above manifests file
  - Deployed in Azure Public cloud.
3. You do not need to provide access to the cluster in public cloud, only the code  
  - Also provided rancher access for 1 one day to check deployment and also multi-cloud k8's cluster management.
4. Your code is clean and readable
  - I hope entire code is clean and readable
5. You must document any steps that are not automated in the README.md
  - Documented all steps that are automated and not automated in the README.md
6. You must have dedicated service account for deployment
  - Created dedicated service account for deployment
7. You must have NodePort Type of service for application
  - Created NodePort Type of service for application
8. You must have Minimum 2 pods always up and running
  - Allocated minimum 2 pods always up and running
9. You must have only 1 pod unavailable during Rolling Update of Deployment
  - Allocated only 1 pod unavailable during Rolling Update of Deployment
```

## Assumptions
```
1. Can use any open-source tools/language to solve problem
  - Used Gitlab for store code and pipeline
  - Used Trivy for container scanning
  - Custom gitlab-runner and below tools installed in centos which running on GCP
    - Git
    - Java, Maven installed
    - Azure CLI installed for login to azure 
    - Trivy installed
    - Docker installed
    - Kubectl service installed 
2. Create extra code if needed like infra(terraform, scripts) etc in same repo
  - Created AKS cluster using terraform script add in same repo
3. Choose simple applications from internet e.g. nginx, httpd
  - Used Java User Management Apllication with Mysql DB
```

## Bonus
```
1. Deployment container is scanned before getting deployed. If severity is high, pipeline should fail
  - Yes the Trivy scanner included and added condition to fail the pipeline
2. Container in Pod, should not be running as root
  - Yes not a root user
3. Provide any code that you required to accomplish this task
  - Provided Terraform Azure AKS Cluster provisioning code
  - Provided Java and Mysql Based Microservices App Code
  - Provided Gitlab Pipeline Code
  - Provided App Deployment Kubenetes manifests
4. You must document any steps that are not automated in the README.md
  - Documented all steps
```
# Pre-requisites
```
- Created AKS cluster using terraform script add in same repo
- GitLab Account
- Install Gitlab Runner and also installed
  - Trivy
  - Kubectl
  - Azure Cli
  - Docker
  - Java
  - Maven
- Created Required Kubemanifest files and add in repo
- Created Pipeline using .gitlab-ci.yml
  -stages:
    - dependency
    - build
    - trivyscanner
    - pushtocr
    - deployment
    - zapscanner

```
# Implementation Part
## Step-01: Introduction
```
- Created a kubernetes deployment, svc, hpa, pdb service account in kubernetes cluster
- Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. 
- Storing confidential information in a Secret is safer and more flexible than putting it directly in a Pod definition or in a container image. 
```

## Step-02: Created Secret for MySQL environment DB Password  
```
'dbpassword11' changed to base64 format
 URL: https://www.base64encode.org
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
