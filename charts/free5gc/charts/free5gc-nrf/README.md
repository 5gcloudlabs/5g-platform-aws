# free5GC NRF Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Network Repository Function (NRF) on a public cloud environment, specifically optimized for Amazon EKS.

The NRF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:

- Maintaining the Network Function (NF) registration and discovery database  
- Supporting service discovery for other 5GC network functions  
- Facilitating interactions between network functions via the Service-Based Architecture (SBA)  
