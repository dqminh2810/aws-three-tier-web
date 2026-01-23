# Create namespace
kubectl apply -f ./k8s/namespace.yaml


# Create a service that points to the RDS endpoint
kubectl apply -f ./k8s/database-service.yaml


# Test connection & Running the database migrations job
kubectl run debug-pod --rm -it --image=postgres -- bash
# kubectl exec -it debug-pod -- /bin/bash
```
PGPASSWORD="password" psql -d testdb -U admin -p 4511 -h postgres-db.3-tier-app-eks.svc.cluster.local
CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));    
INSERT INTO transactions (id, amount,description) VALUES ('0', '400','groceries');   
SELECT * FROM transactions;
```


# Create a secret and configmaps with RDS DB details
echo 'admin' | base64
echo 'password' | base64
echo 'postgresql://admin:password@postgres-db.3-tier-app-eks.svc.cluster.local:4511/testdb' | base64


# Login to docker & Create K8s docker registry secrets
docker login -u <YOUR_USERNAME>
kubectl create secret docker-registry docker-reg-creds --from-file="$HOME/.docker/config.json" --namespace=3-tier-app-eks


# Create backend & frontend docker image , then push to docker registry
****Create docker repositories app-tier & web-tier****
## backend
cd application-code/app-tier
docker build -t app-tier .
docker tag app-tier dqminh2810/app-tier:v01
docker push dqminh2810/app-tier:v01
# ## frontend
cd application-code/web-tier
docker build -t web-tier .
docker tag web-tier dqminh2810/web-tier:v01
docker push dqminh2810/web-tier:v01


# Start the backend and frontend deployments.
kubectl apply -f ./k8s/backend.yaml
kubectl apply -f ./k8s/frontend.yaml 


# Quick test connections
## Port forward backend & frontend
kubectl port-forward -n 3-tier-app-eks svc/backend 4000:4000
kubectl port-forward -n 3-tier-app-eks svc/frontend 8000:80
# ## Test
curl localhost:4000/transaction
curl localhost:8000/api/transaction


# Setup Nginx Ingress Controller
## Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm.list
sudo apt-get update
sudo apt-get install helm
helm version

## Add helm repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

## Install Nginx Ingress Controller
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb

## **Pull docker image manually if helm didnt work
# docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.5@sha256:03a00eb0e255e8a25fa49926c24cde0f7e12e8d072c445cdf5136ec78b546285
 
## Check installed properly
kubectl get pods --namespace=ingress-nginx
kubectl get services --namespace=ingress-nginx


# Setup Ingress Resource
## Create ingress class and resource
kubectl apply -f ./k8s/ingress.yaml

## Check the ingress and load balancer controller logs
kubectl get ingress -n 3-tier-app-eks
kubectl describe ingress 3-tier-app-ingress -n 3-tier-app-eks

