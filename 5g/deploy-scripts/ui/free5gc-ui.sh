#!/bin/sh
# Load variables from ConfigMap mounted file
set -a 
. /free5gc-variables/vars.env
set +a 

# Substitute variables
envsubst <  /git-repo/5g/argocd-apps/free5gc-app/free5gc-app.base > /tmp/free5gc-app.yml 
envsubst '$mcc,$mnc' < /git-repo/5g/deploy-scripts/ui/subscriber-provisioner-ui.base > /tmp/subscriber-provisioner-ui.sh
envsubst '$mcc,$mnc' < /git-repo/5g/argocd-apps/ueransim-app/ueransim-app.base > /tmp/ueransim-app.tmp

# Add executable permissions to script:
chmod u+x /tmp/subscriber-provisioner-ui.sh


# Apply free5gc yml file:
kubectl apply -f /tmp/free5gc-app.yml
