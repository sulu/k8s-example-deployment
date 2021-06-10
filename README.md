# Sulu Kubernetes Example Deployment

This repository demonstrates how to deploy a Sulu application to a Kubernetes cluster using the [sulu/helm-charts](https://github.com/sulu/helm-charts).

The default branch of the repository contains a clean Sulu application based on the [sulu/skeleton](https://github.com/sulu/skeleton).
The changes for adding the deployment are shown in the [pull request #1](https://github.com/sulu/k8s-example-deployment/pull/1).

### 1. Build your container

```
docker build . --target project -t eu.gcr.io/sulu-io/sulu-cluster:1.0.0
docker push eu.gcr.io/sulu-io/sulu-cluster:1.0.0
```

### 2. Create Cluster

```
gcloud beta container --project "sulu-io" clusters create "my-first-cluster-1" --zone "europe-west3-c" --no-enable-basic-auth --cluster-version "1.19.9-gke.1900" --release-channel "regular" --machine-type "g1-small" --image-type "COS" --disk-type "pd-standard" --disk-size "32" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "3" --no-enable-stackdriver-kubernetes --enable-ip-alias --network "projects/sulu-io/global/networks/default" --subnetwork "projects/sulu-io/regions/europe-west3/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0
```

### 3. Connect to cluster

```
gcloud container clusters get-credentials my-first-cluster-1 --zone europe-west3-c --project sulu-io
```

### 4. Create service account

Download the key and add cloud-storage admin permissions to the service account in a bucket.

### 5. Configure secret values

Copy the `deploy/secrets.dist.yaml` to `deploy/secrets.yaml`.

Configure the redis password and the google cloud credentials in the secrets file.

### 6. Install App

```
cd deploy
helm dep build
helm install sulu-cluster . -f secrets.yaml --set=sulu.app.image.tag=1.0.0
```

### 7. Upgrade App

```
cd deploy
helm upgrade sulu-cluster . -f secrets.yaml --set=sulu.app.image.tag=1.0.1
```
