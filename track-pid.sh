#/bin/sh

TRACK_PID=$1
bpftool map \
     create /sys/fs/bpf/capable type hash key 1 value 1 entries 1024 \
     name mntnsset flags 0

MNT_NS_ID=`./ocipidinfo $TRACK_PID | awk '/MntNS: / { print $2 }'`

echo $MNT_NS_ID

/usr/sbin/bpftool map update pinned /sys/fs/bpf/capable \
	key $MNT_NS_ID \
	value 0 any

/usr/share/bcc/tools/capable --mntnsmap /sys/fs/bpf/capable "$@"
