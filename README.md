# deploy promethus on K3S

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm dependency update

argocd app delete prometheus --cascade
argocd app terminate-op prometheus


