# Azure Kubernetes Service (AKS) Deployment Guide

This guide explains how to deploy the Flask Portfolio App to Azure Kubernetes Service (AKS).

## Prerequisites

1. **Azure Kubernetes Service (AKS) cluster** - Create one if you don't have it
2. **ACR attached to AKS** - AKS needs permission to pull images from ACR
3. **kubectl** - Kubernetes CLI tool

## Step 1: Create AKS Cluster (if not exists)

```bash
# Create AKS cluster
az aks create \
  --resource-group flask-portfolio-rg \
  --name flask-portfolio-aks \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --location southeastasia \
  --node-vm-size Standard_B2s \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 3

# Attach ACR to AKS (allows AKS to pull images from ACR)
az aks update \
  --resource-group flask-portfolio-rg \
  --name flask-portfolio-aks \
  --attach-acr zlacr2026
```

## Step 2: Get AKS Credentials

```bash
# Get credentials for kubectl
az aks get-credentials \
  --resource-group flask-portfolio-rg \
  --name flask-portfolio-aks \
  --overwrite-existing

# Verify connection
kubectl get nodes
```

## Step 3: Update Pipeline Variables

In `azure-pipelines.yml`, update these variables:

```yaml
variables:
  # Azure Kubernetes Service (AKS) settings
  aksResourceGroup: 'flask-portfolio-rg'
  aksClusterName: 'flask-portfolio-aks'
```

## Step 4: Update Secret

Update `k8s/secret.yaml` with your actual SECRET_KEY:

```yaml
stringData:
  SECRET_KEY: "your-actual-secret-key-here"
```

## Step 5: Deploy

The pipeline will automatically deploy to AKS. You can also deploy manually:

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create secret
kubectl apply -f k8s/secret.yaml

# Create ACR pull secret
kubectl create secret docker-registry acr-secret \
  --namespace flask-portfolio \
  --docker-server=zlacr2026.azurecr.io \
  --docker-username=<your-acr-username> \
  --docker-password=<your-acr-password>

# Deploy application
kubectl apply -f k8s/deployment.yaml

# Create service
kubectl apply -f k8s/service.yaml
```

## Step 6: Verify Deployment

```bash
# Check pods
kubectl get pods -n flask-portfolio

# Check services
kubectl get svc -n flask-portfolio

# Get external IP
kubectl get svc flask-portfolio-service -n flask-portfolio

# View logs
kubectl logs -l app=flask-portfolio -n flask-portfolio

# Describe pod (for troubleshooting)
kubectl describe pod -l app=flask-portfolio -n flask-portfolio
```

## Architecture

```
Internet
    |
    v
LoadBalancer Service (Port 80)
    |
    v
Flask Portfolio Pods (Port 5004)
    |
    v
ACR (Container Registry)
```

## Kubernetes Resources

| Resource | Purpose |
|----------|---------|
| **Namespace** | Isolates resources for this app |
| **Secret** | Stores SECRET_KEY and ACR credentials |
| **Deployment** | Manages Flask app pods (2 replicas) |
| **Service** | Exposes app via LoadBalancer |

## Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment flask-portfolio --replicas=5 -n flask-portfolio

# Autoscale (optional)
kubectl autoscale deployment flask-portfolio \
  --min=2 --max=10 --cpu-percent=70 \
  -n flask-portfolio
```

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod -l app=flask-portfolio -n flask-portfolio
```

### Image pull error
- Verify ACR credentials secret is created
- Check ACR is attached to AKS: `az aks show --name flask-portfolio-aks --resource-group flask-portfolio-rg --query "identityProfile"`

### Service not accessible
```bash
kubectl get events -n flask-portfolio
```

## Cleanup

```bash
# Delete all resources
kubectl delete namespace flask-portfolio

# Or delete individual resources
kubectl delete -f k8s/
```

## Additional Resources

- [AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Kubernetes Basics](https://kubernetes.io/docs/concepts/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
