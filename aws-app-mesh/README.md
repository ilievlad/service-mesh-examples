# AWS App-Mesh

## Install

### Kubernetes

``` bash
helm repo add eks https://aws.github.io/eks-charts
helm upgrade -i appmesh-controller eks/appmesh-controller \
    --namespace appmesh-system \
    --set region=$AWS_REGION \
    --set serviceAccount.create=true \
    --set serviceAccount.name=appmesh-system
```

To test the above installation apply manifests in `finance` folder:

``` bash
kubectl -n app-mesh-demo apply -f gateway/
kubectl -n app-mesh-demo apply -f finance
```

For services to be allowed to join the mesh, IAM authentication has to be provided. One way is the serviceAccount way:

Create the following policy. Replace all {} with correct values:

``` json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "appmesh:StreamAggregatedResources",
            "Resource": [
                "arn:aws:appmesh:{AWS_REGION}:{ACCOUNT_NUMBER}:mesh/{NAMESPACE}/{ResourceType}/{ResourceName}"
            ]
        }
    ]
}
```

Then apply this policy in AWS and create the service account with eksctl:

``` bash
aws iam create-policy --policy-name ingress-gw-mesh-access --policy-document file://ingress-gw-SA.json

eksctl create iamserviceaccount \
    --cluster $CLUSTER_NAME \
    --namespace $NAMESPACE \
    --name ingress-gw \
    --attach-policy-arn  arn:aws:iam::$ACCOUNT_NUMBER:policy/ingress-gw-mesh-access \
    --override-existing-serviceaccounts \
    --approve
```


## Conclusions

* Since this is aws managed it could be a good solution for us.
* It's a bit more complex than kuma (in setting it up). So that might require more time to learn it.
* There are several resources that need to be created for the service to join the mesh.
* Envoy authentication is made via IAM Roles (simply with serviceAccounts).
* Even though it provides UI for Mesh resrouces, I didn't find a way to see if mesh services are up and running (this was very obvious with other resources).
