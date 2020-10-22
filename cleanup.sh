#!/bin/bash

echo "Remove pre-start hook"
rm -f /host/etc/containers/oci/hooks.d/capabilities_tracker.json


echo "Remove unused bin"
for i in capabilities-tracker capable-hook ocipidinfo ; do
  echo "Removing /usr/local/bin/$i ..."
  rm -f /host/usr/local/bin/$i
done

exit 0
