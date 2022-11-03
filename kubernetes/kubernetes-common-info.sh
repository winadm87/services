#!/bin/bash
##################################
# How-to and basics of kubernetes
# Author Artyom Ivanov
# Created 10.2022
# Version 1.0
##################################
# ################################
# installation on ubuntu block
sudo swapoff -a
# disable swap in fstab
sudo nano /etc/fstab
====
#/swap.img      none    swap    sw      0       0
====

sudo apt install apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d
sudo apt update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
# stop utils form auto update!
sudo apt-mark hold kubeadm kubelet kubectl

# enable bridged traffic
sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# Changing Docker Cgroup Driver
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=cgroupfs"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF

# install docker

# initialize kuber master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

#####################################
# if next command show error "sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR CRI]: container runtime is not running: output: E1026 10:03:17.754997   10985 remote_runtime.go:948] "Status from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"
time="2022-10-26T10:03:17Z" level=fatal msg="getting status of runtime: rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"
# we can run two commands
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bak
sudo systemctl restart containerd
# and then rerun init command
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
######################################

# run his from standart user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# initialize network - flannel in our case
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
# check status
kubectl get pods --all-namespaces
# !!! change daemon to use cgroupfs insted of systemd on master and workers
sudo nano /etc/docker/daemon.json
====
"exec-opts": ["native.cgroupdriver=cgroupfs"],
====
sudo nano /var/lib/kubelet/config.yaml
====
#cgroupDriver: systemd
cgroupDriver: cgroupfs

====

# get component status
kubectl get cs

# get kube nodes
kubectl get nodes

# for single node enable pods to run on master
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all  node-role.kubernetes.io/control-plane-

# create basic deployment
kubectl create deployment nginx --image=nginx
# check its parameters
kubectl describe deployment nginx
# make the pod accessable
kubectl create service nodeport nginx --tcp=80:80
# list all kube services
kubectl get svc
# we can browser to http://masternodip:port, port can be found in previous command
#we can delete deployment by
kubectl delete deployment nginx

# remove node from cluster
#kubectl drain  <node-name> --delete-local-data --ignore-daemonsets
#kubectl cordon <node-name>
#sudo kubeadm reset

# installation block finished
###################################

###################################
# statuses, infos, logs block
#get cluster info
kubectl cluster-info
# get nodes infomartion
kubectl get nodes -o wide
# get pods on system
kubectl get pods
# get more info about running pod
kubectl describe pods k8s
# run a pod from repository image
kubectl run k8s --image=winadm87/k8sapp --port 80
# delete a pod
kubectl delete pod k8s
# run a command inside a running pod
kubectl exec k8s -- date
# and once more
kubectl exec k8s -- cat /usr/share/nginx/html/index.html
kubectl exec k8s -- ls -al /usr/share/nginx/html
# run shel on the runninng pod
kubectl exec -it k8s bash
# show log of pod
kubectl logs k8s
# show kubectl events
kubectl get events --sort-by='.metadata.creationTimestamp' -A
# get events from journalctl
journalctl -u k3s | grep "invalid capacity"
# get all pods info + system pods
watch kubectl get pods --all-namespaces
kubectl get pods -n kube-system
# get pods in another namespace - "projectcontour"
kubectl get pods -n projectcontour -o wide
# get services in another namespace - "projectcontour"
kubectl get svc -n projectcontour -o wide
# get ingress parameters
kubectl get ingress
kubectl describe ingress
# statuses, infos, logs block finished
###################################

###################################
# pods management block
# create a pod
kubectl run k8s --image=winadm87/k8sapp --port 80
# delete a pod
kubectl delete pod k8s
# run a command inside a running pod
kubectl exec k8s -- date
# and once more
kubectl exec k8s -- cat /usr/share/nginx/html/index.html
kubectl exec k8s -- ls -al /usr/share/nginx/html
# run shel on the runninng pod
kubectl exec -it k8s bash
# forward a local port to pod exposed port
kubectl port-forward k8s 8080:80
# make localhost listen on all interfaces
kubectl port-forward k8sproj 8080:80 --address='0.0.0.0'

# pods management block finished
###################################

###################################
# work with deployments block
# create a deployment 
kubectl create deployment winadm --image winadm87/k8sapp
# get deploy info
kubectl describe deploy winadm
# scale a deployment
kubectl scale deploy winadm --replicas 3
# the above command create a replicaset (rs), show its info
kubectl get rs
# create autoscale
kubectl autoscale deploy winadm --min=4 --max=5 --cpu-percent=80
# get autoscale info, hpa = horizontal pod autoscale
kubectl get hpa
# get deploy history
kubectl rollout history deploy winadm
# get deploy status
kubectl rollout status deploy winadm
# update image in deployment
kubectl set image deploy winadm     k8sapp=winadm87/k8sapp:verion1 --record
#                        ^deploy    ^deploy name      ^new 
# once again get history
kubectl rollout history deploy winadm
# rollout to previous deploy version
kubectl rollout undo deploy winadm
# rollout to exact version
kubectl rollout undo deploy winadm --to-revision 1
# restart deploy if we changed something
kubectl rollout restart deploy winadm
# create a basic manifest file
==================
apiVersion : apps/v1
kind : Deployment
metadata:
  name: my-web-deploy
  labels:
    app: myk8sapp
    owner: winadm
spec:
  selector:
    matchLabels:
      project: kgb
  template:
    metadata:
      labels:
        project: kgb
    spec:
      containers:
         - name: kgb-web
           image: winadm87/k8sapp:version1
           ports:
             - containerPort: 80
====================
# apply basic manifest file
kubectl apply -f deploy-1.yaml
# create basic manifest with replicas inside
====================
apiVersion : apps/v1
kind : Deployment
metadata:
  name: my-web-deploy-2
  labels:
    app: myk8sapp2
    owner: winadm
    env: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      project: cia
  template:
    metadata:
      labels:
        project: cia
    spec:
      containers:
         - name: cia-web
           image: winadm87/k8sapp:version1
           ports:
             - containerPort: 80
======================
# apply manifest
kubectl apply -f deploy-2.yaml
# create manifest with atupscaler
======================
apiVersion : apps/v1
kind : Deployment
metadata:
  name: my-web-deploy-3
  labels:
    app: myk8sapp2
    owner: winadm
    env: prod
spec:
  replicas: 2
  selector:
    matchLabels:
      project: kotik
  template:
    metadata:
      labels:
        project: kotik
    spec:
      containers:
         - name: kotik-web
           image: winadm87/k8sapp:version2
           ports:
             - containerPort: 80

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-autoscaling
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-web-deploy-3
  minReplicas: 2
  maxReplicas: 4
  metrics:
   - type: Resource
     resource:
       name: cpu
       target:
         type: Utilization
         averageUtilization: 70
   - type: Resource
     resource:
       name: memory
==========================
$ check the new autoscaler
kubectl get hpa
# work with deployments block finished
###################################

###################################
# work with services block
# expose with service ClusterIP
kubectl expose deploy winadm2 --type=ClusterIP --port 80
# get current services
kubectl get svc
# delete service
kubectl delete service winadm2
# expose with service NodePort
kubectl expose deploy winadm2 --type=NodePort --port 80
# expose load balancer
kubectl expose deploy winadm2 --type=LoadBalancer --port 80
# get svc parameters
kubectl describe svc
# create manifest with svc
=================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web-dep
  labels:
    app: k8sdep
    owner: winadm87
spec:
  replicas: 3
  selector:
    matchLabels:
      project: kgb
  template:
    metadata:
      labels:
        project: kgb  #service look this for those PODs
    spec:
      containers:
        - name: kgb-web
          image: winadm87/k8sapp:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-single-pod-service
  labels:
    env: prod
    owner: winadm87
spec:
  selector:
    project: kgb   #selecting pods with label kgb
  ports:
    - name: app-listener
      protocol: TCP
      port: 80        # port on loadbalancer
      targetPort: 80  #port on pod
  type: LoadBalancer #type of service

=================
# manifest with multiple containers and services
=================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mywebdeploy-multi
  labels:
    app: k8sapp
    owner: winadm87
spec:
  replicas: 3
  selector:
    matchLabels:
      project: cia
  template:
    metadata:
      labels:
        project: cia
    spec:
      containers:
        - name: my-web
          image: winadm87/k8sapp:latest
          ports:
            - containerPort: 80 #port on pod
        - name: my-web2
          image: winadm87/k8sapp:version2
          ports:
            - containerPort: 8080 #port on pod
---
apiVersion: v1
kind: Service
metadata:
  name: mywebdeploy-multi
  labels:
    env: pod
    owner: winadm87
spec:
  type: LoadBalancer
  selector:
    project: cia
  ports:
    - name: my-web-listener
      protocol: TCP
      port: 80
      targetPort: 80
    - name: my-web-2-listener
      protocol: TCP
      port: 8080   # loadbalancer port
      targetPort: 8080 #pod port
=================
# create manifest with deploy, autoscaing and service
=================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web-dep
  labels:
    app: my-web-dep-lab
    owner: winadm
spec:
  selector:
    matchLabels:
      project: xyz
  template:
    metadata:
      labels:
        project: xyz
    spec:
      containers:
        - name: xyz-web
          image: winadm87/k8sapp:latest
          ports:
            - containerPort: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-autoscaling
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-web-dep-autoscaling
  minReplicas: 2
  maxReplicas: 4
  metrics:
   - type: Resource
     resource:
       name: cpu
       target:
         type: Utilization
         averageUtilization: 70
   - type: Resource
     resource:
       name: memory
       target:
         type: Utilization
         averageUtilization: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-autoscaling-pod-service
  labels:
    env: prod
    owner: winadm
spec:
  selector:
    project: xyz
  ports:
    - name: app-listener
      protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
=================
# work with services block finished
###################################

###################################
# woking with ingree controller block
# intall contour ingress controller
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
# create ingress yaml
==============

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-hosts
spec:
  rules:
  - host: www.winadm87.net
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: main
              port:
                number: 80
  - host: web1.winadm87.net
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web1
              port:
                number: 80
  - host: web2.winadm87.net
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web2
              port:
                number: 80

==============
# get ingress parameters
kubectl get ingress
kubectl describe ingress
# woking with ingree controller block finished
###################################

###################################
# add a new node to extisting cluster block
#    7  sudo sudo swapoff -a
#    8  sudo nano /etc/fstab
#    9  sudo mount -a
#   10  sudo apt-get update
#   11  sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
#   12  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#   13  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#   14  sudo apt-get update
#   15  sudo apt-get install docker-ce docker-ce-cli containerd.io
#   16  sudo systemctl status docker
#   17  sudo usermod -aG docker kubadmin
#   18  id -nG
#   19  ip a
#   20  sudo nano /etc/hosts
#   21  ping srv-kub1
#   22  sudo apt -y install curl apt-transport-https
#   23  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#   24  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#   25  sudo apt update
#   26  sudo apt -y install git kubelet kubeadm kubectl
#   27  sudo apt-mark hold kubelet kubeadm kubectl
#   28  sudo modprobe br_netfilter
#   30  sudo sysctl net.bridge.bridge-nf-call-iptables=1
#   33  sudo mkdir /etc/docker
#   34  cat <<EOF | sudo tee /etc/docker/daemon.json
#   35  { "exec-opts": ["native.cgroupdriver=cgroupfs"],
#   36  "log-driver": "json-file",
#   37  "log-opts":
#   38  { "max-size": "10m" },
#   39  "storage-driver": "overlay2"
#   40  }
#   41  EOF
#   45  sudo systemctl enable docker
#   46  sudo systemctl daemon-reload
#   47  sudo systemctl restart docker
#   48  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#   49  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
#   50  kubectl get pods --all-namespaces
#   51  kubectl get componentstatus
#   52  kubeadm join 192.168.126.141:6443 --token ol5oga.08zxfhf2ctbdjqhz --discovery-token-ca-cert-hash sha256:1d6974201c9591c0c06b6d765553ba733eec961cbd469b689ec7a1dc9494f859
#   53  exit
#   54  kubeadm join 192.168.126.141:6443 --token ol5oga.08zxfhf2ctbdjqhz --discovery-token-ca-cert-hash sha256:1d6974201c9591c0c06b6d765553ba733eec961cbd469b689ec7a1dc9494f8593   
#   55  docker images
#   56  sudo systemctl status  containerd
#   57  sudo kubeadm join 192.168.126.141:6443 --token ol5oga.08zxfhf2ctbdjqhz --discovery-token-ca-cert-hash sha256:1d6974201c9591c0c06b6d765553ba733eec961cbd469b689ec7a1dc9494f859
#   58  sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
#   59  docker images
#   60  sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bak
#   61  sudo systemctl restart containerd
#   62  sudo kubeadm join 192.168.126.141:6443 --token ol5oga.08zxfhf2ctbdjqhz --discovery-token-ca-cert-hash sha256:1d6974201c9591c0c06b6d765553ba733eec961cbd469b689ec7a1dc9494f859
# add a new node to extisting cluster block finished
#######################################


#######################################
# work with helm block
# install helm
wget https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -zxvf helm-v3.10.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /bin
# create a folder structure
└── helmcharts
    ├── Chart.yaml
    ├── templates
    │   ├── app-depoy.yaml
    │   └── service.yaml
    └── values.yaml
# lets create some files
# Chart.yaml - contains metadata for our helm deployment
============
apiVersion: v2
name: App-HelmChart
description: My helm chart for kuber-buber
type: application
version: 0.1.0         #this is helm chart version
appVersion: "1.0.0"    #this is application version

keyword:
  - apache
  - http
  - https
  - winadm87

maintainers:
  - name: Artyom Ivanov
    email: win.adm87@gmail.com
    url: www.github.com
============
# values.yaml contains variables with default values
============
# default values for helm chart
container:
  image: winadm87/k8sapp:latest
replicaCount: 2
============
# app-depoy.yaml contains main deployment info
============
#{{ .Release.Name }} - builtin variable for helm
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deploy
  labels:
    app: {{ .Release.Name }}-deploy
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      project: {{ .Release.Name }}
  template:
    metadata:
      labels:
        project: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Release.Name }}-web
          image: {{ .Values.container.image }}
          ports:
            - containerPort: 80
============
# service.yaml contains info about service deploy
============
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
  labels:
    env: prod
    owner: winadm87
spec:
  selector:
    project: {{ .Release.Name }}
  ports:
    - name: {{ .Release.Name }}-listener
      protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
============
# now lets deploy our helm chart
helm install testapp helmcharts/
# lets get helm deploy info
helm list
# lets deploy helmchart with some not default values
helm install testapp2 helmcharts/ --set container.image=winadm87/k8sapp:version1 --set replicaCount=3
# lets upgrade deployd helm chart
helm upgrade testapp2 helmcharts/ --set container.image=winadm87/k8sapp:version1 --set replicaCount=2
# lets look at hb for ready-to-go charts
helm search hub nginx
# add custom repo to search helms
helm repo add bitnami https://charts.bitnami.com/bitnami
# search chart in repo
helm search repo
# install a chart from repo
helm install my-release bitnami/apache
# lets delete deployed app
helm delete testapp2
# work with helm block finished
#######################################
