### assumption
```
1. 가용성 테스트 시나리오는 애플리케이션 워크로드 서비스의 무중단을 가정하여 플랫폼의 장애시 애플리케이션 영향도를 정의함					
2. 고가용성은 고가용 인프라(AZ, Network)와 그 위에 고가용으로 구성된 쿠버네티스 클러스터를 가정함					
3. 테스트 대상 Application Deployment예제에 대해 애플리케이션 레벨에서의  사용자 세션, 데이터에 대한 분산 처리 여부에 대한 테스트는 제외함  					
4. 클러스터 장애시 수동 복구 절차는본 문서에서 제외					
```

### preparation
```
- 고가용 TKC Cluster 준비(Control Plane VM 3
Worker VM 2+)
- Worker VM은 VM 한 개로 application workload를 수용할 수 있는 VM용량(CPU, MEMORY) 구성
- Management Cluster의 MHC(Machine Healthcheck)기능을 활성화 확인 (kubectl get machinehealthchecks  azr-sectkg -o yaml의 spec 섹션
- k8s worker node VM은 2개이상으로 구성하고 cloud에서 제공하는 AZ에 분산되도록한다
- 테스트 대상 Deployment의 replicaset은 2개 이상으로 구성하여  서로 다른 worker node VM에 분산되도록한다. (Deployment에 podAntiAffinity rule을 설정)
- Cluster는 정상동작 중
- node health timeout (default 5min) : Management Cluster에서 kubectl get machinehealthchecks  azr-sectkg -o yaml 를 실행해서) : spec.unhealthConditions
- pod eviction timeout설정 확인:   TkC controlplane에 pod-eviction-timout이 선언되어있지 않으면 default 5분.  TkC controlplane VM > /etc/kubernetes/manifests/kube-controller-manager.yml 의 command section
- Deployment는 Ready상태의 노드에서만 실행되도록 설정한다. (Deployment에 tolerations설정: default 5분)
- core dns deployment의 replica:  default 2
- Application Deployment의 테스트 환경 구성과 동일하게 구성

```

### worker node shutdown
```
- Node health timeout이 지나면 node의 상태는 not-ready로 되고 MHC기능이 새로운 VM을 생성한다.

- node의 상태가 ready상태가 아니면 pod는 termination상태가 된다.

- pod eviction timeout이 되면 가용한 VM에서 pod가 생성된다.
```

### 2/3 control plane node shutdown
```
- TKC- controlplane 서비스는 정상동작한다. Cluster Quorom이 정상상태
-  Application Deployment 서비스는 정상동작된다.
- cluster 메타정보 변경가능(pod scale, PV변경등)
- antrea-controller가 동작중인 VM이 다운되어 antrea-controller pod가 복구되는 동안 core DNS가 영향을 받을 수 있음.??
- core DNS POD가 동작중인 VM이 다운되어 pod 1개로 되고  cluster 내부 DNS lookup은 장애
- 복구하려면 수동으로 VM 전원켜기 필요
```
### all controlplane node shutdown
```
- TKC- controlplane 서비스는 중단된다. Cluster Quorom이 장애상태로 되어 Core dns는 장애상태, etcd 장애. cluster 메타정보 변경불가 (pod scale, PV변경등)
-  Application Deployment 서비스는 정상동작된다. 단 core dns장애로 cluster 내부 DNS lookup불가
- worker node에서 서비스 되는 PV정상 서비스 단, PV변경은 불가
- 복구하려면 수동으로 VM 전원켜기 필요
```
