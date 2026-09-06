#!/bin/sh
set -e

echo "Waiting for Elasticsearch..."
until curl -sf "http://es:9200/_cluster/health" -u "elastic:qwerty123456" > /dev/null 2>&1; do
  sleep 2
done

echo "Setting kibana_system password..."
curl -sf -X POST "http://es:9200/_security/user/kibana_system/_password" \
  -u "elastic:qwerty123456" \
  -H 'Content-Type: application/json' \
  -d '{"password":"qwerty123456"}' > /dev/null && echo "kibana_system password set"

echo "Creating admin user..."
curl -sf -X POST "http://es:9200/_security/user/admin" \
  -u "elastic:qwerty123456" \
  -H 'Content-Type: application/json' \
  -d '{"password":"qwerty123456","roles":["superuser"]}' > /dev/null && echo "admin user created"

echo "Done"
exit 0