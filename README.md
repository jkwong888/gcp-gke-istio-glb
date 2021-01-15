# Using Istio with Standalone NEGs

Istio ingress gateway will by default create a TCP load balancer.  In GKE we want to use istio for east/west traffic and combine ingress, which is all HTTP traffic, into the cluster with features of the HTTPS load balancers in GCP to take advantage of features like:
* global load balancing/backends in multiple regions/backends
* Cloud Armor
* IAP
* TLS termination outside of the cluster (and managed certificate generation)

## Steps

### Create a GKE cluster

Create a GKE cluster using the console, commandline, or terraform.

It's recommended to turn on Workload Identity in this cluster as it allows us to limit the permissions of the autoneg controller that calls GCP APIs to connect services to Load Balancer backends.

### Create a load balancer

Create an HTTPS load balancer with an empty backend.  We'll be attaching backend services that correspond the the istio ingress gateway later.

I have created a terraform with the sample load balancer and workload identity service accounts and roles.



### install the autoneg controller

Follow the instructions [here](https://github.com/GoogleCloudPlatform/gke-autoneg-controller) to install the autoneg controller.  this will automatically connect services with the right annotations to a backend service we created earlier.




###  Install istio 1.8 using Istio Operator

Using the istioctl tool, install the istio operator into the cluster.  This places a controller into `istio-operator` namespace by default and a pod called `istio-operator` that watches a custom resource definition and rolls out Istio based on the spec.

```
istioctl operator init
```

Dump the `default` profile into a yaml.  I've got the custom resource dumped out to this git repo.

```
istioctl profile dump default > my-istio-control-plane.yaml
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
            cloud.google.com/neg: '{"exposed_ports": {"80":{"name": "istio-ingressgateway-80"},"443":{"name": "istio-ingressgateway-443"}}}'
```

you can use my yaml, or make your own

apply this to the `istio-system` namespace

```
kubectl create namespace istio-system
kubectl apply -f istio-default.yaml
```
 
OR

```
kubectl apply -f my-istio-control-plane.yaml
```

