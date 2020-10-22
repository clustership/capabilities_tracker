#!/bin/bash

set -e

if [ ! -r /host/etc/os-release ] ; then
  echo "$0 must be executed in a pod with access to the host via /host" >&2
  exit 1
fi

echo -n "OS detected: "
grep PRETTY_NAME= /host/etc/os-release|cut -d= -f2-

echo -n "Kernel detected: "
uname -r

# gobpf currently uses global kprobes via debugfs/tracefs and not the Perf
# Event file descriptor based kprobe (Linux >=4.17). So unfortunately, kprobes
# can remain from previous executions. Ideally, gobpf should implement Perf
# Event based kprobe and fallback to debugfs/tracefs, like bcc:
# https://github.com/iovisor/bcc/blob/6e9b4509fc7a063302b574520bac6d49b01ca97e/src/cc/libbpf.c#L1021-L1027
# Meanwhile, as a workaround, delete probes manually.
# See: https://github.com/iovisor/gobpf/issues/223
### echo "-:pfree_uts_ns" >> /sys/kernel/debug/tracing/kprobe_events 2>/dev/null || true
### echo "-:pcap_capable" >> /sys/kernel/debug/tracing/kprobe_events 2>/dev/null || true

WORKDIR=/opt/tools/capabilities_tracker
CRIO=0
if grep -q '^1:name=systemd:.*/crio-[0-9a-f]*\.scope$' /proc/self/cgroup > /dev/null ; then
    echo "CRI-O detected."
    CRIO=1
fi

if [ "$RUNC_HOOK_MODE" = "auto" ] ; then
  if [ "$CRIO" = 1 ] ; then
    echo "runc hook mode cri-o detected."
    RUNC_HOOK_MODE="crio"
  elif [ "$FLATCAR_EDGE" = 1 ] ; then
    echo "runc hook mode flatcar_edge detected."
    RUNC_HOOK_MODE="flatcar_edge"
  else
    RUNC_HOOK_MODE="podinformer"
    echo "Falling back to podinformer runc-hook-mode."
  fi
fi

if [ "$RUNC_HOOK_MODE" = "flatcar_edge" ] ||
   [ "$RUNC_HOOK_MODE" = "crio" ] ||
   [ "$RUNC_HOOK_MODE" = "ldpreload" ] ; then
  echo "Installing hooks scripts on host..."

  mkdir -p /host/usr/local/bin/
  for i in capabilities-tracker capable-hook ocipidinfo ; do
    echo "Installing $i..."
    cp ${WORKDIR}/$i /host/usr/local/bin/
  done

  # sed -i "s@%NODE%@-node $NODE_NAME@g" /host/opt/bin/runc-hook-{prestart,poststop}.sh

  if [ "$RUNC_HOOK_MODE" = "crio" ] ; then
    echo "Installing OCI hooks configuration in /etc/containers/oci/hooks.d/"
    mkdir -p /host/etc/containers/oci/hooks.d/
    cp ${WORKDIR}/capabilities_tracker.json /host/etc/containers/oci/hooks.d/capabilities_tracker.json
    # cp /opt/crio-hooks/gadget-poststop.json /host/etc/containers/oci/hooks.d/gadget-poststop.json
  fi

  echo "Installation done"
fi

### POD_INFORMER_PARAM=""
### if [ "$RUNC_HOOK_MODE" = "podinformer" ] ; then
###   POD_INFORMER_PARAM="-podinformer"
### fi

### echo "Starting the Gadget Tracer Manager in the background..."
### rm -f /run/gadgettracermanager.socket
### /bin/gadgettracermanager -serve $POD_INFORMER_PARAM &

### if [ "$INSPEKTOR_GADGET_OPTION_TRACELOOP" = "true" ] ; then
###   rm -f /run/traceloop.socket
###   if [ "$INSPEKTOR_GADGET_OPTION_TRACELOOP_LOGLEVEL" != "" ] ; then
###     exec /bin/traceloop -log "$INSPEKTOR_GADGET_OPTION_TRACELOOP_LOGLEVEL" k8s
###   else
###     exec /bin/traceloop k8s
###   fi
### fi

echo "Ready."
sleep infinity
