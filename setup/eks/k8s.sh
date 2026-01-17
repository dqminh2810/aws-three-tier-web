# Create namespace
kubectl apply -f ./k8s/namespaces.yaml


# Create a service that points to the RDS endpoint
kubectl apply -f ./k8s/database-service.yaml


# Test connection & Running the database migrations job
kubectl run debug-pod --rm -it --image=postgres -- bash
kubectl exec -it debug-pod -- /bin/bash
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


#kubectl create secret docker-registry docker-reg-creds --docker-server="docker.io" --docker-username="dqminh2810" --docker-password="password1234!!" --docker-email="dqminh2810@gmail.com"
# Login to docker & Create K8s docker registry secrets
docker login -u <YOUR_USERNAME>
kubectl create secret docker-registry docker-reg-creds --from-file="$HOME/.docker/config.json"


# Create backend & frontend docker image , then push to docker registry
****Create docker repositories app-tier & web-tier****
## backend
cd application-code/app-tier
docker build -t app-tier .
docker tag app-tier dqminh2810/app-tier:v01
docker push dqminh2810/app-tier:v01
## frontend
cd application-code/web-tier
docker build -t web-tier .
docker tag web-tier dqminh2810/web-tier:v01
docker push dqminh2810/web-tier:v01


# Start the backend and frontend deployments.
kubectl apply -f ./k8s/backend.yaml
kubectl apply -f ./k8s/frontend.yaml 


# Port forward backend & frontend
kubectl port-forward -n 3-tier-app-eks svc/backend 4000:4000
kubectl port-forward -n 3-tier-app-eks svc/frontend 8000:80
## Test
curl localhost:4000/transaction
curl localhost:8000/api/transaction