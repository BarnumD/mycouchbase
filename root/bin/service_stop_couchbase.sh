#!/bin/bash

## Do some sanity checks before we begin shutting things down.
# Check couchbase rebalance status
result=$(/opt/couchbase/bin/couchbase-cli rebalance-status -c localhost:8091 -u $CB_REST_USERNAME -p $CB_REST_PASSWORD)
if [[ $result == *"running"* || $result == *"Running"* ]]; then
  echo -n "There is an active rebalance ongoing.  Waiting.."
  while [[ $result == *"running"* || $result == *"Running"* ]];do
    result=$(/opt/couchbase/bin/couchbase-cli rebalance-status -c localhost:8091 -u $CB_REST_USERNAME -p $CB_REST_PASSWORD)
      echo -n "."
    sleep 1
    let wait=$wait+1
    if (($wait > 60)); then
      echo "Waited too long"
      wait=0
      break
    fi
  done
fi

## Put CouchBase on this node into 'failover'
# We cannot just use typical failover because it doesn't reshard unless you take the node out of the cluster entirely.  In other words, you wouldn't be able to take more than one node down.
# Therefore, we use server-remove
result=$(/opt/couchbase/bin/couchbase-cli rebalance -c localhost:8091 --server-remove $DOCKERHOSTNAME -u $CB_REST_USERNAME -p $CB_REST_PASSWORD)
echo $result