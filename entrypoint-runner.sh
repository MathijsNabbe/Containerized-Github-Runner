#!/bin/bash
set -e

# ---- FIX: make dotnet available to GitHub Actions jobs ----
export DOTNET_ROOT=/usr/share/dotnet
export PATH="$DOTNET_ROOT:$PATH"

cd /home/runner/actions-runner

LABELS="self-hosted"
[ -n "$RUNNER_LABELS" ] && LABELS="$LABELS,$RUNNER_LABELS"

NAME="${RUNNER_NAME:-Self-Hosted Github Runner}"

if [ ! -f .runner ]; then
  echo "⚙️ Configuring the runner..."
  ./config.sh --unattended \
    --url "$REPO_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$NAME" \
    --work _work \
    --labels "$LABELS"
else
  echo "ℹ️ Runner already configured, skipping registration."
fi

echo "🚀 Starting runner..."
exec ./run.sh
