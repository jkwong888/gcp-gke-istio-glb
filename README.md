# Using Istio with Standalone NEGs

Istio ingress gateway will by default create a TCP load balancer.  In GKE we want to use istio for east/west traffic and combine ingress, which is all HTTP traffic, into the cluster with features of the HTTPS load balancers in GCP to take advantage of features like:
* global load balancing/backends in multiple regions/cluster
* [Cloud Armor](https://cloud.google.com/armor)
* [Identity Aware Proxy](https://cloud.google.com/iap)
* TLS termination outside of the cluster (and managed certificate generation)

## Steps

### Create a GKE cluster

Create a GKE cluster using the console, commandline, or terraform.

It's recommended to turn on Workload Identity in this cluster as it allows us to limit the permissions of the autoneg controller that calls GCP APIs to connect services to Load Balancer backends.

I have created a terraform with the sample load balancer, GKE cluster, and workload identity service accounts and roles, in the `gclb-terraform` directory.

### Create a load balancer

Create an HTTPS load balancer with an empty backend.  We'll be attaching backend services that correspond the the istio ingress gateway later.

I have created a terraform with the sample load balancer, GKE cluster, and workload identity service accounts and roles, in the `gclb-terraform` directory.

### install the autoneg controller

[GKE autoneg controller](https://github.com/GoogleCloudPlatform/gke-autoneg-controller) is a project that uses the [Standalone NEGs](https://cloud.google.com/kubernetes-engine/docs/how-to/standalone-neg?hl=nl) feature in GKE and dynamically adds services to load balancer backends based on an annotation.  this will automatically connect services to the backend service we created earlier using terraform.

```
kubectl apply -f autoneg.yaml
```

add the annotation to the service account to map the workload identity service account created by terraform to the kubernetes service account.  In terraform, the service account was named `autoneg-system@<project-id>.iam.gserviceaccount.com`.

```
kubectl annotate sa -n autoneg-system autoneg-system \
  iam.gke.io/gcp-service-account=autoneg-system@${PROJECT_ID}.iam.gserviceaccount.com
```


###  Install istio 1.8 using Istio Operator

Using the istioctl tool, install the istio operator into the cluster.  This places a controller into `istio-operator` namespace by default and a pod called `istio-operator` that watches a custom resource definition and rolls out Istio based on the spec.

```
kubectl apply -f istio-operator.yaml
```

I also have `istio-default.yaml`, created by dumping the `default` profile into a yaml and making some edits for the autoneg controller.  I've got the custom resource dumped out to this git repo already, but here is how it was created:

```
istioctl profile dump default > istio-default.yaml
```

The main sections to change here are under the ingress gateway, where we want to make `istio-ingressgateway` a `ClusterIP` service type and add the annotations so the NEG controller running in GKE generates network endpoint groups that can be used in HTTPS load balancers.

```
   ingressGateways:
    - enabled: true
      k8s:
        ...
        service:
          type: ClusterIP
        ...  
        serviceAnnotations:
            cloud.google.com/neg: '{"exposed_ports": {"80":{"name": "istio-ingressgateway-80"}}}'
            anthos.cft.dev/autoneg: '{"name":"istio-http", "max_rate_per_endpoint":1000}'
```

HTTP traffic served by istio-ingressgateway is presented as a network endpoint group (NEG) in GCP.  The Autoneg controller will connect this to the `istio-http` backend automatically.

you can use my yaml, or make your own

```
kubectl apply -f istio-default.yaml
```

### Deploy a workload

Deploy a simple http service by following the istio docs.  


