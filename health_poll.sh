#!/usr/bin/env bash

POLL_INTERVAL=30

while true; do
  # 8000 = Django (web)
  status_web=$(curl -s --max-time 5 --connect-timeout 3 -o /dev/null -w "%{http_code}" http://0.0.0.0:8000/systems/healthcheck/)
  if [[ "$status_web" != "200" ]]; then
    echo "$(date) | Web healthcheck failed (status: $status_web). Restarting web in background..."
    restart web >/dev/null 2>&1 &
  fi

  # 9000 = SSR
  status_ssr=$(curl -s --max-time 5 --connect-timeout 3 -o /dev/null -w "%{http_code}" http://0.0.0.0:9000/system/ready/)
  if [[ "$status_ssr" != "200" ]]; then
    echo "$(date) | SSR healthcheck failed (status: $status_ssr). Restarting ssr in background..."
    restart ssr >/dev/null 2>&1 &
  fi

  # 8001 = fallback / infra
  status_fallback=$(curl -s --max-time 5 --connect-timeout 3 -o /dev/null -w "%{http_code}" http://0.0.0.0:8001/system/ready/)
  if [[ "$status_fallback" != "200" ]]; then
    echo "$(date) | 8001 ready check failed (status: $status_fallback). Running dc up -d in background..."
    dc up -d >/dev/null 2>&1 &
  fi

  sleep "$POLL_INTERVAL"
done
