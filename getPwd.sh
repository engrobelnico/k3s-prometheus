#!/bin/bash

# https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad

# Set the `errexit` option to make sure that
# if one command fails, all the script execution
# will also fail (see `man bash` for more 
# information on the options that you can set).
set -o errexit

main () {
    sudo kubectl -n argocd get secret prometheus-grafana -o jsonpath="{.data.admin-password}" -n prometheus | base64 -d; echo
}
main "$@"