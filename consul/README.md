# Consul

## Installation

For this exmple, consul will be installed as server in kubernetes and clients for external VMs.

### Kubernetes

Modify [config.yaml](config.yaml) file and update `certificate-arn`, `hostname` and `api-hostname` to the proper values.
Install via helm chart using config.yaml as values.

``` bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm upgrade -i -n consul consul hashicorp/consul -f config.yaml --version 0.47.1 --create-namespace
```

To test the above installation apply manifests in `echo` folder:

``` bash
kubectl -n consul apply -f ingress-gateway/
kubectl -n consul apply -f splitter/
kubectl -n consul apply -f finance/
kubectl -n consul apply -f nginx-external/ # this is to configure intentions and routes for VM service installed later
```

After deployment, Console UI should show echo service and it should start serving under `<api-hostname>/echo`

### External VM

To install on a external vm, a EC2 instance will be used. Make sure instance is in the same VPC and has access to k8s pods ips (check security groups and subnets).

Installation consist of installing consul agent and envoy:

#### Agent

``` bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install consul-1.13.1-1.x86_64
```

Copy:

* `vmConfig/consul.service` in `/etc/systemd/system` in VM to enable service.
* `acl.hcl`, `nginx-external-service.json` and `acl.hcl` to `/etc/consul.d`
* consul-ca-cert from kubernetes secret `consul/certs/consul-ca-cert.pem` to `/etc/consul.d`

Set the following env vars (needed for envoy bootstrapping):

``` bash
export CONSUL_CACERT=/etc/consul.d/certs/consul-agent-ca.pem
export CONSUL_CLIENT_CERT=/etc/consul.d/certs/dc1-client-consul-0.pem
export CONSUL_CLIENT_KEY=/etc/consul.d/certs/dc1-client-consul-0-key.pem
```

make sure everything is owned by consul:

``` bash
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl
```

Start consul agent by:

``` bash
sudo systemctl enable consul
sudo systemctl start consul
```

verify consul members by:

``` bash
consul members
```

Command above should show k8s consul server members plus the new agent added.

#### Envoy

``` bash
export ENVOY_VERSION_STRING=1.22.2
sudo curl -L https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
func-e use $ENVOY_VERSION_STRING
sudo cp ~/.func-e/versions/$ENVOY_VERSION_STRING/bin/envoy /usr/local/bin/
envoy --version
```

## Running a service

With all of the above, node is ready for app installation. For demo purposes, either install nginx, or any web app. Make sure it's exposed via port 8080. Otherwise, change service config in `nginx-external-service.json`.

### Running envoy as sidecar

``` bash
consul connect envoy -sidecar-for nginx-external -token=<get token from service definition>
```

## Gotchas

* First of all, consul documentation, even tough is very thorough, it's very hard to navigate. To setup the above demo, it took about 3 days of digging into consul documentation.
* Any pod that needs to be into the mesh has to have a service selecting it even if it only consumes mesh traffic and doesn't expose anything.
* Multi port services are not supported, so services need to be split into multiple services. An annotation has to be added to the pod to specify which services are selecting it.
* Cleanup of resources (when deleting a namespace, for example) has to be done in a certain order because of finalisers. ServiceDefaults have to be deleted before the services and pods, otherwise, custom resources will not be deleted (could be a bug in the custom resource definitions).
* Gateway ingress is exposed via a LoadBalancer service. It has a health check port that is different than the ports used for traffic so that has to be added as annotation for NLB to mark target as healthy.
* VM agents need to use a provider to autodiscover the k8s consul cluster. One such provider is k8s but it needs kubectl, kubeconfig and aws-cli and access to k8s api (read only).
* VM sidecar setup is not trivial.
