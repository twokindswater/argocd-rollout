# istio-rollout

1. helm install istio-rollout
```shell
helm install istio-rollout ./istio-rollout
```

단) namespace에 istio-injection option이 활성화 되어있어야 함
```shell
kubectl label namespace {{ NAMESPACE }} istio-injection=enabled
```

2. component validate 
```shell
(base)  js@node1  ~/project/jieum/spc-jieum-cicd   main  k get ro
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
rollouts-demo   1         1         1            1           2m53s
(base)  js@node1  ~/project/jieum/spc-jieum-cicd   main  k get svc                
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                                      AGE
rollouts-demo-canary   ClusterIP      10.102.121.174   <none>         80/TCP                                       3m49s
rollouts-demo-stable   ClusterIP      10.102.22.84     <none>         80/TCP                                       3m49s
(base)  js@node1  ~/project/jieum/spc-jieum-cicd   main  k get virtualservices                     
NAME                     GATEWAYS                    HOSTS                           AGE
rollouts-demo-vsvc1      ["rollouts-demo-gateway"]   ["rollouts-demo-vsvc1.local"]   3m57s
rollouts-demo-vsvc2      ["rollouts-demo-gateway"]   ["rollouts-demo-vsvc2.local"]   3m57s
(base)  js@node1  ~/project/jieum/spc-jieum-cicd   main  k get gateways                     
NAME                    AGE
rollouts-demo-gateway   4m19s

```
rollout status 
```shell

(base)  ✘ js@node1  ~/project/jieum/spc-jieum-cicd   main  k argo rollouts get rollout rollouts-demo
Name:            rollouts-demo
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          2/2
  SetWeight:     100
  ActualWeight:  100
Images:          asia-northeast3-docker.pkg.dev/jieum-dev/jongsoo/manager:2.0 (stable)
Replicas:
  Desired:       1
  Current:       1
  Updated:       1
  Ready:         1
  Available:     1

NAME                                      KIND        STATUS     AGE    INFO
⟳ rollouts-demo                           Rollout     ✔ Healthy  5m58s  
└──# revision:1                                                         
   └──⧉ rollouts-demo-9f568496d           ReplicaSet  ✔ Healthy  5m58s  stable
      └──□ rollouts-demo-9f568496d-sqsf4  Pod         ✔ Running  5m58s  ready:2/2

```

3. /etc/hosts 파일 virtual service hosts정보에 맞게 수정하기
```shell
cat /etc/hosts 
# test
34.64.222.79      rollouts-demo-vsvc2.local 
34.64.222.79       rollouts-demo-vsvc1.local

```
4. curl.sh 파일에 LB endpoint 적기
```shell
URL="http://rollouts-demo-vsvc1.local"
```
5. run curl.sh
```shell
v2.0 count: 164(100.00%), v3.0 count: 0(0.00%)
```
6. image 변경 (v2.0 -> v3.0)
```shell
k argo rollouts set image rollouts-demo rollouts-demo=asia-northeast3-docker.pkg.dev/jieum-dev/jongsoo/manager:3.0
```

7. curl.sh 확인 
```shell
v2.0 count: 329(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 330(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 331(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 332(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 333(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 334(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 335(95.00%), v3.0 count: 14(4.00%)
v2.0 count: 336(96.00%), v3.0 count: 14(4.00%)
v2.0 count: 337(96.00%), v3.0 count: 14(3.00%)
v2.0 count: 337(95.00%), v3.0 count: 15(4.00%)
```

8. virtual service 는 처음에 100 : 0 으로 되어있었는데 rollout 이후 95:5로 변경됨(spec.steps.setWeight: 5)
```shell
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollouts-demo
spec:
  replicas: 1
  strategy:
    canary:
      canaryService: rollouts-demo-canary
      stableService: rollouts-demo-stable
      trafficRouting:
        istio:
          virtualServices:
            - name: rollouts-demo-vsvc1 # At least one virtualService is required
              routes:
                - primary # At least one route is required
            - name: rollouts-demo-vsvc2
              routes:
                - secondary # At least one route is required
      steps:
        - setWeight: 5
        - pause: {}
```

9. virtual service 확인 (weight 95:5 로 변경됨) 
```shell
k describe virtualservices rollouts-demo-vsvc1
Name:         rollouts-demo-vsvc1
Namespace:    default
Labels:       app.kubernetes.io/managed-by=Helm
Annotations:  meta.helm.sh/release-name: istio-rollout
              meta.helm.sh/release-namespace: default
API Version:  networking.istio.io/v1
Kind:         VirtualService
Metadata:
  Creation Timestamp:  2024-05-31T08:16:05Z
  Generation:          3
  Resource Version:    16711445
  UID:                 d0278bcf-0ccc-4299-a1d6-fa7d3e2dfcda
Spec:
  Gateways:
    rollouts-demo-gateway
  Hosts:
    rollouts-demo-vsvc1.local
  Http:
    Name:  primary
    Route:
      Destination:
        Host:  rollouts-demo-stable
        Port:
          Number:  80
      Weight:      95
      Destination:
        Host:  rollouts-demo-canary
        Port:
          Number:  80
      Weight:      5

```

10. promotion 
```shell
k argo rollouts promote rollouts-demo
```

11. rollout status (stable이 terminated됨)
```shell
k argo rollouts get rollout rollouts-demo 
Name:            rollouts-demo
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          2/2
  SetWeight:     100
  ActualWeight:  100
Images:          asia-northeast3-docker.pkg.dev/jieum-dev/jongsoo/manager:3.0 (stable)
Replicas:
  Desired:       1
  Current:       1
  Updated:       1
  Ready:         1
  Available:     1

NAME                                       KIND        STATUS         AGE    INFO
⟳ rollouts-demo                            Rollout     ✔ Healthy      2d18h  
├──# revision:2                                                              
│  └──⧉ rollouts-demo-76f48588b6           ReplicaSet  ✔ Healthy      41m    stable
│     └──□ rollouts-demo-76f48588b6-p8scd  Pod         ✔ Running      41m    ready:2/2
└──# revision:1                                                              
   └──⧉ rollouts-demo-6c8dbd4fb7           ReplicaSet  • ScaledDown   2d18h  
      └──□ rollouts-demo-6c8dbd4fb7-xxx4g  Pod         ◌ Terminating  16h    ready:2/2
```

12. curl.sh 확인 (모든 traffic이 v3.0으로 전환됨)  
```shell

v2.0 count: 467(80.00%), v3.0 count: 112(19.00%)
v2.0 count: 467(80.00%), v3.0 count: 113(19.00%)
v2.0 count: 467(80.00%), v3.0 count: 114(19.00%)
v2.0 count: 467(80.00%), v3.0 count: 115(19.00%)
v2.0 count: 467(80.00%), v3.0 count: 116(19.00%)
v2.0 count: 467(79.00%), v3.0 count: 117(20.00%)
v2.0 count: 467(79.00%), v3.0 count: 118(20.00%)
v2.0 count: 467(79.00%), v3.0 count: 119(20.00%)
v2.0 count: 467(79.00%), v3.0 count: 120(20.00%)
v2.0 count: 467(79.00%), v3.0 count: 121(20.00%)
v2.0 count: 467(79.00%), v3.0 count: 122(20.00%)
v2.0 count: 467(79.00%), v3.0 count: 123(20.00%)
```
