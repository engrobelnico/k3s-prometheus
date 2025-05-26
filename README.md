# deploy promethus on K3S

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm dependency update

argocd app delete prometheus --cascade
argocd app terminate-op prometheus

sudo kubectl describe service traefik --namespace kube-system
sudo kubectl get servicemonitor --namespace prometheus
sudo kubectl describe service --all-namespaces | grep -i nodeport

https://k3s.rocks/metrics/

https://github.com/cablespaghetti/k3s-monitoring/blob/master/traefik-servicemonitor.yaml
https://github.com/mmatur/prometheus-traefik

argocd app delete prometheus --cascade
argocd app terminate-op prometheus
sudo kubectl patch application/prometheus --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]' -n argocd
