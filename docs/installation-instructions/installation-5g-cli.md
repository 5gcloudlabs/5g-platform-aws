### 5. End-to-End 5G Network Deployment:  
Deploy the 5G Core, provision test subscribers, and launch the UE & gNB simulation — either via CLI or Console-UI.

#### A) 5G Network Deployment via CLI:

##### 1. Deploy 5G Core via CLI

Use the provided **bash script** in the repository to trigger the 5G Core deployment.

Navigate to the `scripts/cli` directory and run the deployment script:

```bash
cd aws-5gcloudlabs/scripts/cli
./free5gc-cli.sh
```

You will be prompted to enter the PLMN-ID for your Network, here we input 602 as value for mcc and 02 as value for mnc

Example prompt: 
```bash
Configure the PLMN-ID for your 5G Core Network (MCC + MNC).

1. Enter a 3-digit Mobile Country Code (MCC), example: 602
2. Enter a 2-digit Mobile Network Code (MNC), example: 02

```

Expected Output. you should see output similar to: 
```bash
application.argoproj.io/free5gc-app created
```



###### Validate the 5G Core Deployment

This section verifies the 5G Core deployment and auto-integration by checking Network Function pod status, 3GPP SBI service registration in the NRF, Multus-based multi-NIC pods for traffic separation, and N4 interface connectivity between the SMF and UPF.

1. Validate 5G Core Pod Status

Check that all Free5GC pods are starting correctly and reaching a Running status.

```bash
kubectl -n free5gc get pods
NAME                                                   READY   STATUS    
aws-5gcloudlabs-free5gc-amf-amf-f69db95f-f6csq         2/2     Running   
aws-5gcloudlabs-free5gc-ausf-ausf-585956b99c-zn82d     2/2     Running   
aws-5gcloudlabs-free5gc-nrf-nrf-549dd59dc4-xwxq7       2/2     Running   
aws-5gcloudlabs-free5gc-nssf-nssf-778f45f96c-zrqcn     2/2     Running   
aws-5gcloudlabs-free5gc-pcf-pcf-68b4f8fb7c-cs6lq       2/2     Running   
aws-5gcloudlabs-free5gc-smf-smf-cb7944cc5-24nth        2/2     Running   
aws-5gcloudlabs-free5gc-udm-udm-7476888578-s896f       2/2     Running   
aws-5gcloudlabs-free5gc-udr-udr-cb876bdf6-5f9f5        2/2     Running   
aws-5gcloudlabs-free5gc-upf-upf-67dd5464f4-975zp       2/2     Running   
aws-5gcloudlabs-free5gc-webui-webui-6876d69c77-8bldv   2/2     Running   
mongodb-0                                              2/2     Running   
```

2. Validate SBI Registration (NF Registration Check)


Free5GC network functions (AMF, SMF, AUSF, UDM, etc.) register with the NRF over the Service-Based Interface (SBI).

You can verify that a Network Function is successfully registered by checking its entry in the NRF database. The NRF stores its registrations inside MongoDB (along with other Free5GC databases).

Specify nfType (e.g UDM) in the command below to verify the NF registration:

```bash
kubectl -n free5gc exec -it mongodb-0 -- mongo free5gc --eval 'db.NfProfile.find({ nfType: "UDM" }).pretty()'
```

Expected Output:


You only need to verify the key fields shown below (your real output will contain many more details):

```bash
{
  "nfType": "UDM",
  "nfStatus": "REGISTERED",
  "plmnList": [
     { "mcc": "602", "mnc": "02" }
    ],
  "ipv4Addresses": ["aws-5gcloudlabs-free5gc-udm-service"],
  "nfServices": [
    { "serviceName": "nudm-ee",   "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-pp",   "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-sdm",  "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-uecm", "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-ueau", "nfServiceStatus": "REGISTERED" }
  ]
}

```



3. Validate that traffic-separated NFs (AMF, SMF, and UPF) have multiple network interfaces with IP addresses automatically allocated via Whereabouts from the designated Multus subnets.

- Verify AMF Network Interfaces:

```bash
kubectl -n free5gc exec -it $(kubectl -n free5gc get pod -l nf=amf -o name) -- ip address show
```

Expected Outcome:
Verify that the AMF pod has a dedicated N2 interface attached along side the default Kubernetes interface.

```bash
eth0@if26: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 9001 qdisc noqueue state UP 
link/ether 7e:eb:9d:b1:44:66 brd ff:ff:ff:ff:ff:ff
inet 192.168.100.206/32 scope global eth0

n2@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UNKNOWN qlen 1000
link/ether 0a:e8:cb:25:bc:71 brd ff:ff:ff:ff:ff:ff
inet 100.64.1.10/28 brd 100.64.1.15 scope global n2
```

The example above is a trimmed excerpt of the output (e.g loopback interface is omitted).

- Verify SMF Network Interfaces:

```bash
kubectl -n free5gc exec -it $(kubectl -n free5gc get pod -l nf=smf -o name) -- ip address show
```

Expected Outcome:

Verify that the SMF pod has a dedicated N4 interface attached along side the default Kubernetes interface.

```bash
eth0@if30: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 9001 qdisc noqueue state UP 
link/ether b6:aa:9a:72:87:58 brd ff:ff:ff:ff:ff:ff
inet 192.168.122.253/32 scope global eth0

n4@n4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UNKNOWN qlen 1000
link/ether 0a:e7:73:16:f4:69 brd ff:ff:ff:ff:ff:ff
inet 100.64.4.10/28 brd 100.64.4.15 scope global n4
```

The example above is a trimmed excerpt of the output (e.g loopback interface is omitted).

- Verify UPF Network Interfaces

```bash
kubectl -n free5gc exec -it $(kubectl -n free5gc get pod -l nf=upf -o name) -- ip address show
```

Expected Outcome:

Verify that the UPF pod has a dedicated N3, N4 & N6 interfaces attached along side the default Kubernetes interface.

```bash
eth0@if25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default 
link/ether 56:46:cf:95:7c:09 brd ff:ff:ff:ff:ff:ff link-netnsid 0
inet 192.168.59.250/32 scope global eth0

n4@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UNKNOWN group default qlen 1000
link/ether 06:01:7d:14:41:71 brd ff:ff:ff:ff:ff:ff link-netnsid 0
inet 100.64.5.10/28 brd 100.64.5.15 scope global n4

n3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
link/ether 06:84:32:89:40:8b brd ff:ff:ff:ff:ff:ff
altname enp0s6
inet 100.64.3.10/28 brd 100.64.3.15 scope global n3

n6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
link/ether 06:4d:37:87:cd:19 brd ff:ff:ff:ff:ff:ff
altname enp0s8
inet 100.64.6.10/28 brd 100.64.6.15 scope global n6
```

The example above is a trimmed excerpt of the output (e.g loopback interface is omitted).

4. Validate the N4 interface is up between SMF & UPF, by checking the SMF logs. 

```bash
kubectl -n free5gc logs $(kubectl -n free5gc get pod -l nf=smf -o name)
```
Expected Output

You should see the PFCP Association Request and the corresponding ‘Association Setup Accepted’ response from the UPF.


```bash
[INFO][SMF][PFCP] Listen on 100.64.4.10:8805
[INFO][SMF][Main] Sending PFCP Association Request to UPF[100.64.5.10]
[INFO][SMF][Main] Received PFCP Association Setup Accepted Response from UPF[100.64.5.10]
```


##### 2. 5G Subscribers Creation via CLI

After validating that your 5G Core has been successfully deployed, you can proceed to provision 5G subscribers via script.

1. Make sure you are in the same `cli` directory:

```bash
aws-5gcloudlabs/scripts/cli
```

2. Run the Subscriber Provisioning Script

Execute the script*:

```bash
./subscriber-provisioner-cli.sh

```

You will be prompted to enter how many test subscribers you want to provision. In this example, we use 2.

Example prompt: 
```bash
Enter the number of subscribers to provision (e.g: 10): 10
```

Expected Output:
```bash
*** Starting provisioning of (10) subscribers with IMSI range beginning at (602020000000001) ***

Please wait...


===== Provisioned IMSI List =====

602020000000001
602020000000002
602020000000003
602020000000004
602020000000005
602020000000006
602020000000007
602020000000008
602020000000009
602020000000010

```
IMSI numbering starts at $mcc.$mnc.0000000001.

*This script is automatically created when you run free5gc-cli.sh.
The original template file, subscriber-provisioner-cli.base, contains placeholder variables ($mcc, $mnc) which are replaced during the environment substitution step.


###### Validate subscriber provisioning:

The MongoDB instance used by Free5GC stores both NF registration data and the subscriber profile database.

To verify that subscribers were provisioned successfully:

1- list all collections in the free5gc database:

```bash
kubectl -n free5gc exec -it mongodb-0 -- mongo free5gc --eval 'db.getCollectionNames()'
```

Expected output:


You should see the following collections, which are created during subscriber provisioning and are not present by default:

- `policyData.ues.amData`
- `policyData.ues.smData`
- `subscriptionData.authenticationData.authenticationSubscription`
- `subscriptionData.provisionedData.amData`
- `subscriptionData.provisionedData.smData`
- `subscriptionData.provisionedData.smfSelectionSubscriptionData`


The presence of these collections confirms that subscribers were added successfully.

2- Validate an individual subscriber by querying one of these collections.
For example, to inspect the Session Management policy data for a specific IMSI

```bash
kubectl -n free5gc exec -it mongodb-0 -- mongo free5gc --eval 'db.policyData.ues.smData.find({ ueId: "imsi-602020000000001" }).pretty()'
```

Expected Output (key fields):

```bash
{
  "ueId": "imsi-602020000000001",
  "smPolicySnssaiData": {
    "01010203": {
      "snssai": { "sst": 1, "sd": "010203" },
      "smPolicyDnnData": {
        "internet": { "dnn": "internet" },
        "internet2": { "dnn": "internet2" }
      }
    },
    "01112233": {
      "snssai": { "sst": 1, "sd": "112233" },
      "smPolicyDnnData": {
        "internet": { "dnn": "internet" },
        "internet2": { "dnn": "internet2" }
      }
    }
  }
}
```


##### 3. Deploy UERANSIM (UE + gNB) Simulation via CLI

After validating that your 5G test subscribers have been provisioned successfully, you can proceed to deploy **UERANSIM** via script.

1. Make sure you are in the same `cli` directory:

```bash
aws-5gcloudlabs/scripts/cli
```

2. Run the script `ueransim-cli.sh`:

```bash
./ueransim-cli.sh

```

Expected Output. 

you should see output similar to: 

```bash
application.argoproj.io/ueransim-app created
```

###### Validate UERANSIM Deployment

This section validates the UERANSIM deployment and auto-integration by checking gNB and UE pod status, N2 connectivity between the gNB and AMF, and successful UE registration and PDU session establishment.


1. Validate UE & gNB Pod Status

Check that all UERANSIM pods are starting correctly and reaching a Running status.


```bash
kubectl -n ueransim get pods
```

You should see the following pods in Running state:

```bash
kubectl -n ueransim get pods
NAME                                           READY   STATUS    
aws-5gcloudlabs-ueransim-gnb-c4f64d998-5868p   2/2     Running       
aws-5gcloudlabs-ueransim-ue-5685b847d7-vhmn7   2/2     Running     
```


2. Validate the N2 interface is up between gNB & AMF, by checking the gNB logs.

```bash
kubectl -n ueransim logs $(kubectl -n ueransim get pod -l component=gnb -o name) | grep 'sctp\|NG'
```

Expected Outcome:

```bash
[sctp] [info] Trying to establish SCTP connection... (100.64.1.10:38412)
[sctp] [info] SCTP connection established (100.64.1.10:38412)
[sctp] [debug] SCTP association setup ascId[3]
[ngap] [debug] Sending NG Setup Request
[ngap] [debug] NG Setup Response received
[ngap] [info] NG Setup procedure is successful
```

Summary

- SCTP association between the gNB and AMF is successfully established
- NGAP NG Setup procedure completes successfully
- N2 interface connectivity between the gNB and AMF is confirmed

3. Verify UE registration and PDU session establishment, by checking UE pod logs

```bash
kubectl -n ueransim logs $(kubectl -n ueransim get pod -l component=ue -o name)
```



Expected Outcome*:
*(Trimmed excerpt of the output)

```bash
[602020000000001|nas] [info] UE switches to state [MM-DEREGISTERED/PLMN-SEARCH]
[602020000000001|rrc] [debug] New signal detected for cell[1], total [1] cells in coverage
[602020000000001|nas] [info] UE switches to state [MM-DEREGISTERED/NO-CELL-AVAILABLE]
[602020000000001|nas] [info] Selected plmn[602/02]
[602020000000001|rrc] [info] Selected cell plmn[602/02] tac[1] category[SUITABLE]
[602020000000001|nas] [info] UE switches to state [MM-DEREGISTERED/PS]
[602020000000001|nas] [info] UE switches to state [MM-DEREGISTERED/NORMAL-SERVICE]
[602020000000001|nas] [debug] Initial registration required due to [MM-DEREG-NORMAL-SERVICE]
[602020000000001|nas] [debug] Sending Initial Registration
[602020000000001|nas] [info] UE switches to state [MM-REGISTER-INITIATED]
[602020000000001|rrc] [debug] Sending RRC Setup Request
[602020000000001|rrc] [info] RRC connection established
[602020000000001|rrc] [info] UE switches to state [RRC-CONNECTED]
[602020000000001|nas] [info] UE switches to state [CM-CONNECTED]
[602020000000001|nas] [debug] Authentication Request received
[602020000000001|nas] [debug] Received SQN [000000000021]
[602020000000001|nas] [debug] SQN-MS [000000000000]
[602020000000001|nas] [debug] Security Mode Command received
[602020000000001|nas] [debug] Selected integrity[2] ciphering[0]
[602020000000001|nas] [debug] Registration accept received
[602020000000001|nas] [info] UE switches to state [MM-REGISTERED/NORMAL-SERVICE]
[602020000000001|nas] [debug] Sending Registration Complete
[602020000000001|nas] [info] Initial Registration is successful
[602020000000001|nas] [debug] Sending PDU Session Establishment Request
[602020000000001|nas] [debug] UAC access attempt is allowed for identity[0], category[MO_sig]
[602020000000001|nas] [debug] PDU Session Establishment Accept received
[602020000000001|nas] [info] PDU Session establishment is successful PSI[1]
[602020000000001|app] [info] Connection setup for PDU session[1] is successful, TUN interface[uesimtun7, 10.1.0.8] is up.
```

Summary:

- UE detects a suitable cell and selects the target PLMN
- Initial registration is initiated and completed successfully
- Authentication and security procedures complete without errors
- UE transitions to REGISTERED / NORMAL-SERVICE
- PDU session establishment succeeds and the UE data TUN interface is created
- UE `602020000000001` is assigned IP Address `10.1.0.8`


4. Validate UE IP Address Allocation

```bash
kubectl -n ueransim exec -it $(kubectl -n ueransim get pod -l component=ue -o name) -- ip a
```

Expected Outcome:

The `uesimtun(x)` interfaces are created—one per UE—with IP addresses assigned from the UE IP pool (`10.1.0.0/16`) after successful PDU session establishment.

```bash
eth0@if24: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001
inet 192.168.49.23/32 scope global eth0

uesimtun0: <POINTOPOINT,UP,LOWER_UP>
inet 10.1.0.1/32 scope global uesimtun0

uesimtun1: <POINTOPOINT,UP,LOWER_UP>
inet 10.1.0.2/32 scope global uesimtun1

uesimtun2: <POINTOPOINT,PROMISC,NOTRAILERS,UP,LOWER_UP>
inet 10.1.0.3/32 scope global uesimtun2

uesimtun3: <POINTOPOINT,PROMISC,NOTRAILERS,UP,LOWER_UP>
inet 10.1.0.4/32 scope global uesimtun3
```
The example above is a trimmed excerpt of the output.



### 6. End-to-End Network Connectivity Validation:  
This step validates end-to-end user-plane connectivity by generating ICMP traffic from the UE data interface (`uesimtunx`) toward an external destination. Successful ping responses confirm that the UE data path is fully operational across the 5G Core (UE → gNB → UPF → external network) and that NAT and routing through the UPF are correctly configured.

```bash
kubectl -n ueransim exec -it $(kubectl -n ueransim get pod -l component=ue -o name) -- ping -c 4 -I uesimtun0 google.com
```

Expected Outcome:

Successful ICMP responses with zero packet loss confirm end-to-end user-plane connectivity.

```bash
PING google.com (142.250.185.206) from 10.1.0.1 uesimtun0: 56(84) bytes of data.
64 bytes from fra16s52-in-f14.1e100.net (142.250.185.206): icmp_seq=1 ttl=115 time=2.18 ms
64 bytes from fra16s52-in-f14.1e100.net (142.250.185.206): icmp_seq=2 ttl=115 time=2.08 ms
64 bytes from fra16s52-in-f14.1e100.net (142.250.185.206): icmp_seq=3 ttl=115 time=1.84 ms
64 bytes from fra16s52-in-f14.1e100.net (142.250.185.206): icmp_seq=4 ttl=115 time=1.80 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 1.802/1.973/2.183/0.160 ms
```

### Congratulations! 
#### You have successfully validated internet access through a fully functional 5G Core deployed on AWS !


---
