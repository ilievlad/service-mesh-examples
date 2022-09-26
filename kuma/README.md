# Kuma

## Install

### Kubernetes

``` bash
helm repo add kuma https://kumahq.github.io/charts
helm upgrade -i kuma kuma/kuma --create-namespace --namespace kuma-system  -f values.yaml
```

Setup is pretty straight forward for the standalone setup. For the multi-zone setup, a dedicated global cluster is needed.

To test the above installation apply manifests in `echo` folder:

``` bash
kubectl -n kuma-demo apply -f gateway/
kubectl -n kuma-demo apply -f echo/
kubectl -n kuma-demo apply -f finance/
```

After deployment, Kuma UI should show echo service and it should start serving under `<api-hostname>/echo`

### External VM

Universal setup is again straight forward, but to mix K8s and VM loads, a multi-zone setup is required.

### Multi-zone setup

For multi-zone setup, there is need for a global control plane (CP) and one CP for each zone.
The global CP will refuse data plane connections and will only allow zone controll connections.
Also, a global CP and a zone CP cannot be installed in the same k8s cluster.
This means that any load that is installed on the global cluster cannot join the mesh.

## Conclusions

* Kuma is a very easy to use service mesh. Installation and configuration is straight forward and it's using (like all other service mesh solutions) k8s CRD for it's setup.
* The product is still new, but it's production ready.
* At the time of writing, build in gateway was at first GA version.
* It's very lightweight, consisting of only 1 deployment for a control plane. It also only injects one container (a wrapped envoy container).
* It comes with build in observability for easy setup; it's not recommeded for production, though. So we'll have to integrate it with our metrics and logging.
* It has service autodiscovery, meaning no extra objects are needed to join mesh (unlike other solutions)
