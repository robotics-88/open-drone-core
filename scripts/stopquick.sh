#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# --- Gazebo (by PID file) ---
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
REST_PIDS=$(lsof -t -iTCP:8080 -sTCP:LISTEN || true)
if [[ -n "$REST_PIDS" ]]; then
  echo "🛑 Stopping REST API (PIDs: $REST_PIDS)"
  echo "$REST_PIDS" | xargs kill
else
  echo "⚠️  No REST API listening on 8080"
fi
rm -f "$SCRIPT_DIR/rest.pid"

# --- Frontend (port 8040) ---
FE_PIDS=$(lsof -t -iTCP:8040 -sTCP:LISTEN || true)
if [[ -n "$FE_PIDS" ]]; then
  echo "🛑 Stopping Frontend (PIDs: $FE_PIDS)"
  echo "$FE_PIDS" | xargs kill
else
  echo "⚠️  No Frontend listening on 8040"
fi
rm -f "$SCRIPT_DIR/frontend.pid"

# --- ArduPilot terminal (by PID file) ---
if [[ -f "$SCRIPT_DIR/terminal.pid" ]]; then
  TERM_PID=$(<"$SCRIPT_DIR/terminal.pid")
  if kill "$TERM_PID" 2>/dev/null; then
    echo "✅ Stopped Terminal (PID $TERM_PID)"
  else
    echo "⚠️  Terminal PID $TERM_PID not running"
  fi
  rm -f "$SCRIPT_DIR/terminal.pid"
fi
