

1. install
```shell
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
customresourcedefinition.apiextensions.k8s.io/analysisruns.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/analysistemplates.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/clusteranalysistemplates.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/experiments.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/rollouts.argoproj.io created
serviceaccount/argo-rollouts unchanged
clusterrole.rbac.authorization.k8s.io/argo-rollouts created
clusterrole.rbac.authorization.k8s.io/argo-rollouts-aggregate-to-admin created
clusterrole.rbac.authorization.k8s.io/argo-rollouts-aggregate-to-edit created
clusterrole.rbac.authorization.k8s.io/argo-rollouts-aggregate-to-view created
clusterrolebinding.rbac.authorization.k8s.io/argo-rollouts created
configmap/argo-rollouts-config unchanged
secret/argo-rollouts-notification-secret unchanged
service/argo-rollouts-metrics unchanged
deployment.apps/argo-rollouts unchanged
```

2. On GKE, you will need grant your account the ability to create new cluster roles
```shell
kubectl create clusterrolebinding YOURNAME-cluster-admin-binding --clusterrole=cluster-admin --user=YOUREMAIL@gmail.com
```

3. Create a rollout CRD
```shell
kubectl apply -k https://github.com/argoproj/argo-rollouts/manifests/crds\?ref\=stable
customresourcedefinition.apiextensions.k8s.io/analysisruns.argoproj.io configured
customresourcedefinition.apiextensions.k8s.io/analysistemplates.argoproj.io configured
customresourcedefinition.apiextensions.k8s.io/clusteranalysistemplates.argoproj.io configured
customresourcedefinition.apiextensions.k8s.io/experiments.argoproj.io configured
customresourcedefinition.apiextensions.k8s.io/rollouts.argoproj.io configured
```

4. Kubectl Plugin Installation
```shell
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

5. helm install argocd-rollout
```shell
helm install manager-rollout ./manager-rollout
```

6. LB service 생성됨, curl.sh 파일에 LB endpoint 적기
7. rollout watch
```shell
k argo rollouts get rollout manager-demo --watch
```
8. run curl.sh
9. changed image
``` 
kubectl-argo-rollouts set image ROLLOUT_NAME CONTAINER=IMAGE [flags]
```

```shell
k argo rollouts set image manager-demo manager-pod=asia-northeast3-docker.pkg.dev/jieum-dev/jongsoo/manager:2.0
```

``` 
rollout "manager-demo" image updated
```

10. promotion
```shell
kubectl argo rollouts promote rollouts-demo
```
