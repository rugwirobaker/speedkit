#!/usr/bin/env bash
set -eo pipefail
cfg=${1}
if [ "${cfg}" = "" ]; then
  echo "usage: ${0} <fly toml filename>"
  exit 1
fi
machineId=$(fly m list --json -c "${cfg}" | jq '.[] | .id' -r | head -1)
for reg in $(diff <(fly m list --json -c "${cfg}" | jq '.[].region' -r | sort | uniq) <(fly platform regions --json | jq 'sort_by(.Code) | .[] | select(.Code != "maa" and .Code != "lax") | .Code' -r) | grep -E '^> ' | sed -E 's/^> //g'); do
  fly m start -c "${cfg}" "${machineId}" || :
  set -x
  fly m clone --region "${reg}" -c "${cfg}" "${machineId}"
  set +x
done
