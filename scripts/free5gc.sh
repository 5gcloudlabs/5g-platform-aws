#!/bin/bash

echo -e "Configure the PLMN-ID for your 5G Core Network (MCC + MNC).\n"
read -p "1. Enter a 3-digit Mobile Country Code (MCC) [default: 208]: " mcc_
read -p "2. Enter a 2-digit Mobile Network Code (MNC) [default: 93]: " mnc_


# Set environment variables
export mcc=$mcc_
export mnc=$mnc_


# Substitute variables
envsubst < ./free5gc-app.base > ./free5gc-app.yml
envsubst '$mcc,$mnc' < ./subscriber-provisioner.base > ./subscriber-provisioner.sh
envsubst '$mcc,$mnc' < ../4-UERANSIM/ueransim.base > ../4-UERANSIM/ueransim.sh
envsubst '$mcc,$mnc' < ../4-UERANSIM/ueransim-app.base > ../4-UERANSIM/ueransim-app.tmp

# Add executable permissions to script:
chmod u+x ../4-UERANSIM/ueransim.sh

# Apply free5gc yml file:
kubectl apply -f ./free5gc-app.yml
