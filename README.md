# Service Mesh Examples

* [Consul](consul/README.md)
* [Kuma](kuma/README.md)
* [aws-app-mesh](aws-app-mesh/README.md)

## Mesh Comparison

Comparison is extracted from [here](https://www.toptal.com/kubernetes/service-mesh-comparison) and adapted to our needs.

| | Kuma | Consul | AWS App-Mesh |
|---|---|---|---|
| Ingress | any | consul ingress| AWS Ingress Gateway |
| Traffic control setup | easiest | complex | easy |
| Ease of installation | easiest | complex | easy |
| Control Plane | very simple (uses k8s api to store configs  via CRD) | Uses its own key/value store even tough it supports config via CRD. | Managed control plane. No need to worry about HA or resilience |
| Datadog integration | yes | yes | yes |

### Consul Connect

This is not only a service mesh, but it has also a distributed key-value storage.

#### Pros

* Backed up by hashicorp
* Mature and battle tested
* Clean UI with traffic monitoring (showing connectivity with errors between services)

#### Cons

* Documentation is scattered and hard to follow.
* It has a lot of moving parts -> agent, server, client, etc. And also 2 sidecar containers, instead of one like the rest.
* Setup is complex, at least on VMs.
* Service authentication is based on tokens, that have to be passed arround to login (making autodiscovery a bit challanging).
* Each pod in k8s has to have its own service to join the mesh even if that pod is only consuming traffic (a bit odd, at least).

### Kuma

Kuma is a really easy to use service mesh in terms of installation and configuration. But it's fairly new.

#### Pros

* Easy to operate.
* Lightweight in terms of infrastructure - one control plane deployment and one sidecar container.
* Configuration is very easy and very well documented.
* Integrates well with Datadog for tracing and metrics as well as with loki for logging.
* Ingress Gateways are defined using CRD and will autodeploy an envoy pod to serve external traffic.

#### Cons

* It's the yungest project of the ones I've studied, even though it's backed up by Kong and it's a [CNCF Sandbox Project](https://www.cncf.io/projects/kuma/)
* Multi region setup requires a dedicated cluster for the global control plane because GCP can't be on the same cluster as the regional CP.

### AWS App-Mesh

App mesh is an aws managed solution. Meaning we don't have to install much except the app-mesh controller (k8s) that deploys the mesh components.

#### Pros

* It's a managed solution, no installation required and HA provided out of the box.
* It integrates well with eks, ec2, NLB.
* AWS Support

#### Cons

* It's not open sourced.
* A bit more complicated than Kuma in setting up.
* Gateways have to be manually deployed (a basic envoy deployment with certain annotations) instead of having a dedicated CRD.
* Seems a bit excesive with mesh objects that need configuration compared to Kuma. (VirtualService, VirtualNode, VirtualRoute, etc.)
