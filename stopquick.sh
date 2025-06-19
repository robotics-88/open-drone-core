#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# --- Gazebo ---
if [[ -f "$SCRIPT_DIR/gazebo.pid" ]]; then
  GZ_PID=$(<"$SCRIPT_DIR/gazebo.pid")
  if kill "$GZ_PID" 2>/dev/null; then
    echo "✅ Stopped Gazebo (PID $GZ_PID)"
  else
    echo "⚠️  Gazebo PID $GZ_PID not running"
  fi
  rm -f "$SCRIPT_DIR/gazebo.pid"
fi

# --- REST API (port 8080) ---
if lsof -iTCP:8080 -sTCP:LISTEN >/dev/null; then
  REST_PID=$(lsof -t -iTCP:8080 -sTCP:LISTEN)
  kill "$REST_PID" && echo "✅ Stopped REST API (PID $REST_PID)"
else
  echo "⚠️  No REST API listening on 8080"
fi
rm -f "$SCRIPT_DIR/rest.pid"

# --- Frontend (port 8040) ---
if lsof -iTCP:8040 -sTCP:LISTEN >/dev/null; then
  FE_PID=$(lsof -t -iTCP:8040 -sTCP:LISTEN)
  kill "$FE_PID" && echo "✅ Stopped Frontend (PID $FE_PID)"
else
  echo "⚠️  No Frontend listening on 8040"
fi
rm -f "$SCRIPT_DIR/frontend.pid"
