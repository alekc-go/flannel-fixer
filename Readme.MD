# Flannel Fixer

## What is it?
If you are running your k3s cluster on a provider such as scaleway (which assigns a private ip to the instance and routable public ip), you will find that if you try to add a nod from another network (which doesn't use those private ips you will find that the new node will appear as ready, you are able to spawn pods on them, but those pods wont be able to route inside cluster (for example `nslookup kubernetes.default` wont work. 

## How to fix this
The fix is pretty easy. If you have correctly installed your node by passing `--node-external-ip="$(scw-metadata --cached PUBLIC_IP_ADDRESS)"`, and you are able to see public ip of your node by doing `kubectl get nodes -o wide` it means that k3s assigned a special label `k3s.io/external-ip` with your ip to the node. This fixer on startup lists all nodes, if they have the label `k3s.io/external-ip` its value is stored inside `flannel.alpha.coreos.com/public-ip-overwrite` and `flannel.alpha.coreos.com/public-ip` annotations which fixes routing. 

## How to run
You can deploy this fixer by running following yaml on 
```
kubectl apply -f https://raw.githubusercontent.com/alekc-go/flannel-fixer/master/deployment.yaml
```
## Configuration
you should not need to touch these for pod functionality, but still they are 

| ENV Name | Default value | Notes |  
| -- | -- | -- |  
| FFIXER_USER_KUBECONFIG | false | If set to true, then use authentication in kube config (useful for local development/debugging) |
| FFIXER_KUBECONFIG | $HOME/.kube/config | Path for config file, used if FFIXER_USER_KUBECONFIG is enabled  |
