# Flannel Fixer

## What is it?
If you are running your k3s cluster on a provider such as scaleway (which assigns a private ip to the instance and routable public ip), you will find that if you try to add a nod from another network (which doesn't use those private ips you will find that the new node will appear as ready, you are able to spawn pods on them, but those pods wont be able to route inside cluster (for example `nslookup kubernetes.default` wont work. 

## How to fix this
The fix is pretty easy. If you have correctly installed your node by passing `--node-external-ip="$(scw-metadata --cached PUBLIC_IP_ADDRESS)"`, and you are able to see public ip of your node by doing `kubectl get nodes -o wide` it means that k3s assigned a special label `k3s.io/external-ip` with your ip to the node. This fixer on startup lists all nodes, if they have the label `k3s.io/external-ip` its value is stored inside `flannel.alpha.coreos.com/public-ip-overwrite` and `flannel.alpha.coreos.com/public-ip` annotations which fixes routing. 

## How to run
You can deploy this fixer by running following yaml on 
```
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  namespace: kube-system  
  name: flannel-fixer-deployment  
  labels:  
  app: flannel-fixer  
spec:  
  replicas: 1  
  selector:  
  matchLabels:  
  app: flannel-fixer  
  template:  
  metadata:  
  labels:  
  app: flannel-fixer  
    spec:  
  serviceAccountName: flannel-fixer  
      tolerations:  
 - key: "node-role.kubernetes.io/master"  
  operator: "Exists"  
  containers:  
 - name: flannel-fixer  
          image: "alekcander/k3s-flannel-fixer:0.0.1"  
  command:  
 - flannel-fixer  
          ports:  
 - containerPort: 2112  
              name: metrics  
---  
apiVersion: v1  
kind: ServiceAccount  
metadata:  
  name: flannel-fixer  
  namespace: kube-system  
---  
apiVersion: rbac.authorization.k8s.io/v1  
kind: ClusterRole  
metadata:  
  name: flannel-fixer  
  namespace: kube-system  
rules:  
 - apiGroups: [""] # "" indicates the core API group  
  resources: ["nodes"]  
  verbs: ["get", "watch", "list","update"]  
---  
apiVersion: rbac.authorization.k8s.io/v1  
kind: ClusterRoleBinding  
metadata:  
  namespace: kube-system  
  name: flannel-fixer-role-binding  
roleRef:  
  kind: ClusterRole  
  name: flannel-fixer  
  apiGroup: rbac.authorization.k8s.io  
subjects:  
 - kind: ServiceAccount  
    name: flannel-fixer  
    namespace: kube-system
```
## Configuration
you should not need to touch these for pod functionality, but still they are 

| ENV Name | Default value | Notes |  
| -- | -- | -- |  
| FFIXER_USER_KUBECONFIG | false | If set to true, then use authentication in kube config (useful for local development/debugging) |
| FFIXER_KUBECONFIG | $HOME/.kube/config | Path for config file, used if FFIXER_USER_KUBECONFIG is enabled  |
