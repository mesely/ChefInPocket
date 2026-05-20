#!/bin/sh
set -eu

if [ -z "${MONGODB_URI:-}" ]; then
  echo "MONGODB_URI is required."
  exit 1
fi

PIDS=""

start_service() {
  name="$1"
  dir="$2"
  port="$3"
  db_name="$4"

  echo "Starting $name on port $port"
  PORT="$port" DB_NAME="$db_name" MONGODB_URI="$MONGODB_URI" \
    node "$dir/src/server.js" &
  PIDS="$PIDS $!"
}

cleanup() {
  if [ -n "${PIDS# }" ]; then
    kill $PIDS 2>/dev/null || true
  fi
}

trap cleanup INT TERM EXIT

start_service "auth-service" "/app/backend/services/auth-service" "${AUTH_SERVICE_PORT:-5001}" "chef_in_pocket_auth"
start_service "recipe-service" "/app/backend/services/recipe-service" "${RECIPE_SERVICE_PORT:-5002}" "chef_in_pocket_recipe"
start_service "pantry-service" "/app/backend/services/pantry-service" "${PANTRY_SERVICE_PORT:-5003}" "chef_in_pocket_pantry"
start_service "community-service" "/app/backend/services/community-service" "${COMMUNITY_SERVICE_PORT:-5004}" "chef_in_pocket_community"
start_service "assistant-service" "/app/backend/services/assistant-service" "${ASSISTANT_SERVICE_PORT:-5005}" "chef_in_pocket_assistant"
start_service "content-service" "/app/backend/services/content-service" "${CONTENT_SERVICE_PORT:-5006}" "chef_in_pocket_content"

echo "Starting api-gateway on port ${API_GATEWAY_PORT:-8080}"
PORT="${API_GATEWAY_PORT:-8080}" \
AUTH_SERVICE_URL="http://127.0.0.1:${AUTH_SERVICE_PORT:-5001}" \
RECIPE_SERVICE_URL="http://127.0.0.1:${RECIPE_SERVICE_PORT:-5002}" \
PANTRY_SERVICE_URL="http://127.0.0.1:${PANTRY_SERVICE_PORT:-5003}" \
COMMUNITY_SERVICE_URL="http://127.0.0.1:${COMMUNITY_SERVICE_PORT:-5004}" \
ASSISTANT_SERVICE_URL="http://127.0.0.1:${ASSISTANT_SERVICE_PORT:-5005}" \
CONTENT_SERVICE_URL="http://127.0.0.1:${CONTENT_SERVICE_PORT:-5006}" \
node /app/backend/api-gateway/src/server.js &
PIDS="$PIDS $!"

echo "Starting nginx on port ${PORT:-7860}"
nginx -g "daemon off;" &
PIDS="$PIDS $!"

while true; do
  for pid in $PIDS; do
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "A process exited unexpectedly: $pid"
      exit 1
    fi
  done
  sleep 5
done
