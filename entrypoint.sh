#!/bin/bash
set -e

# Ensure required environment variables are set
if [ -z "$REPO_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
  echo "❌ REPO_URL and RUNNER_TOKEN must be set"
  exit 1
fi

DOCKER_SOCKET="/var/run/docker.sock"
if [ -S "$DOCKER_SOCKET" ]; then
    DOCKER_GID=$(stat -c '%g' $DOCKER_SOCKET)

    # Check if a docker group already exists
    if getent group docker >/dev/null 2>&1; then
        # If it exists but with a different GID, adjust it
        EXISTING_GID=$(getent group docker | cut -d: -f3)
        if [ "$EXISTING_GID" != "$DOCKER_GID" ]; then
            groupmod -g $DOCKER_GID docker
        fi
    else
        # Create docker group if missing
        groupadd -g $DOCKER_GID docker
    fi

    # Add runner user to the docker group
    usermod -aG docker runner
fi

# Drop to runner user for actual process
exec gosu runner /home/runner/entrypoint-runner.sh
