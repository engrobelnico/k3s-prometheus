#!/bin/bash

# https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad

# Set the `errexit` option to make sure that
# if one command fails, all the script execution
# will also fail (see `man bash` for more 
# information on the options that you can set).
set -o errexit

main () {
    myNamespace=prometheus
    NS=$(sudo kubectl get namespace $myNamespace --ignore-not-found);
    if [[ "$NS" ]]; then
        echo "Skipping creation of namespace $myNamespace - already exists";
    else
        echo "Creating namespace $myNamespace";
        sudo kubectl create namespace $myNamespace;
    fi;
    # deploy prometheus with argocd
    sudo kubectl apply -n argocd -f prometheus.yaml
    # sync the application
    argocd login kube.local:443 --grpc-web-root-path /argocd-server --insecure  --username admin --password $(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    syncOutput=$(argocd app sync prometheus --grpc-web-root-path /argocd-server 2>&1) || syncExit=$?
    if [[ -n "${syncExit:-}" ]]; then
        if [[ "$syncOutput" == *"another operation is already in progress"* ]]; then
            echo "An Argo CD operation is already running for prometheus, waiting for completion..."
            argocd app wait prometheus --operation --timeout 300 --grpc-web-root-path /argocd-server || true
            argocd app sync prometheus --grpc-web-root-path /argocd-server
        else
            echo "$syncOutput"
            return "$syncExit"
        fi
    fi
    # show access path
    echo "http://kube.local/prometheus"
    echo "http://kube.local/grafana"
    sudo kubectl get secret prometheus-grafana -o jsonpath="{.data.admin-password}" -n prometheus | base64 --decode ; echo

}
main "$@"
