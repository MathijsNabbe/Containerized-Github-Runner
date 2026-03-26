#!/bin/bash
set -e

# Ensure required environment variables are set
if [ -z "$REPO_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
  echo "❌ REPO_URL and RUNNER_TOKEN must be set"
  exit 1
fi

# Run the runner script (already as runner)
exec /home/runner/entrypoint-runner.sh