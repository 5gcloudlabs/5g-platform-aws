#!/bin/bash

echo -e "Configure the PLMN-ID for your 5G Core Network (MCC + MNC).\n"
read -p "1. Enter a 3-digit Mobile Country Code (MCC) [default: 208]: " mcc_
read -p "2. Enter a 2-digit Mobile Network Code (MNC) [default: 93]: " mnc_


# Set environment variables
export mcc=$mcc_
export mnc=$mnc_


# Substitute variables
envsubst < ../../argocd/free5gc-app.base > ../../argocd/free5gc-app.yml
envsubst '$mcc,$mnc' < ./subscriber-provisioner.base > ./subscriber-provisioner.sh
envsubst '$mcc,$mnc' < ./ueransim-cli.base > ./ueransim-cli.sh
envsubst '$mcc,$mnc' < ../../argocd/ueransim-app.base > ../../argocd/ueransim-app.tmp

# Add executable permissions to script:
chmod u+x ./subscriber-provisioner.sh
chmod u+x ./ueransim-cli.sh

# Apply free5gc yml file:
kubectl apply -f ../../argocd/free5gc-app.yml
