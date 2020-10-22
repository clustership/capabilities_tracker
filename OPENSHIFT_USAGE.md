# Using capabilities_tracker on OpenShift

## !WARNING!

Don't use this tool on a production cluster as it is not tested and it breaks security constraints by allowing cluster-admin role to the service account.

## Setup

As cluster administrator run:

```
oc create -f openshift/deploy.yaml
```

It will create new resources on your cluster :
- capabilities-tracker Service Account (with cluster-admin rolebinding)
- capabilities-tracker DaemonSet


Pre-start hooks are create on each cluster nodes.


# Build from source

TO BE DONE.

First build ocipidinfo from the convert directory:
```
go get -u github.com/kinvolk/inspektor-gadget/pkg/gadgettracermanager/containerutils
go build -o ../ocipidinfo main.go
```

Then

```
podman build -t xymox/fedora_capabilities_tracker -f Dockerfile.fedora .
podman tag xymox/fedora_capabilities_tracker <your-tag>
podman push <your-tag>
```

#Usage

Create a pod with the io.containers.trace-capabilities: "true" annotation.

see examples/simple-deployment.yaml

Then get pod uid + compute node info :

```
oc get pods -o wide
```

Then get the capabilities pod running on the same worker (compute) node.

```
oc -n capabilities-tracker get pods -o wide
```

Connect to to capabilities-tracker pods:

```
oc -n capabilities-tracker rsh <pod-uid>
# tail -n1 /infos/capabilities.log | ./track-containers.sh
```


# Notes

Document how to use this as a sidecar container.

Document with we are using mount namespace map (cgroups v2 are not yet available on OpenShift).

Try to automate eBPF tracking and centralize informations for simplier use.

# TODO

Post-stop hook to cleanup bpf map.




