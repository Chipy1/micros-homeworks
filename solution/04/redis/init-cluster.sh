#!/bin/sh
set -e

# Initialize the Redis cluster created by docker-compose.yml.
# Run from the host:
#   cd solution/04/redis && docker compose up -d
#   docker compose exec redis-master-01 sh /usr/local/bin/init-cluster.sh

echo "Waiting for all nodes to be up..."
for host in redis-master-01 redis-master-02 redis-master-03 redis-replica-01 redis-replica-02 redis-replica-03; do
  until redis-cli -h "$host" -p 6379 ping 2>/dev/null | grep -q PONG; do
    sleep 1
  done
  echo "$host is up"
done

echo "=== Creating cluster: 3 masters, 3 replicas (--cluster-replicas 1) ==="
redis-cli --cluster create \
  --cluster-replicas 1 \
  --cluster-yes \
  redis-master-01:6379 \
  redis-master-02:6379 \
  redis-master-03:6379 \
  redis-replica-01:6379 \
  redis-replica-02:6379 \
  redis-replica-03:6379

echo "=== Cluster state ==="
redis-cli -h redis-master-01 -p 6379 cluster info | head -8

echo "=== Cluster nodes ==="
redis-cli -h redis-master-01 -p 6379 cluster nodes

echo "Done. Connect with: redis-cli -h 127.0.0.1 -p 7001 -c"