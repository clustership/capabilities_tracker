#/bin/sh

mkdir -p /sys/fs/bpf/capable

read -r JSON

# bpftool map \
#     create /sys/fs/bpf/capable type hash key 1 value 1 entries 1024 \
#     name mntnsset flags 0

MNT_NS_ID=`echo $JSON | ./ocipidinfo $TRACK_PID | awk '/MntNS: / { print $2 }'`

echo $MNT_NS_ID

bpftool map \
    create /sys/fs/bpf/capable/${MNT_NS_ID} type hash key 1 value 1 entries 1024 \
    name mntnsset flags 0

/usr/sbin/bpftool map update pinned /sys/fs/bpf/capable/${MNT_NS_ID} \
  key $MNT_NS_ID \
  value 0 any

/usr/share/bcc/tools/capable --mntnsmap /sys/fs/bpf/capable/${MNT_NS_ID} "$@"
