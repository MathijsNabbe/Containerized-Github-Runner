# Containerized GitHub Runner

This repository contains a Docker setup for running a **self-hosted GitHub Actions runner** in a containerized environment.  

Running your GitHub runner in a container offers several advantages over using a bare-metal or VM-based runner:

- **Isolation**: Each runner instance runs in its own container, preventing workflows from interfering with each other or with the host system.  
- **Quick Scalability**: You can spin up multiple runner containers simultaneously to handle high workflow demand without manual setup.  
- **Consistency**: The container image defines the environment, ensuring every runner has the same tools, libraries, and configurations.  
- **Easy Maintenance**: Updating dependencies or tools can be done by rebuilding the container image, without impacting running workflows.  
- **Host Resource Access**: By mounting the Docker socket or other host resources, workflows can interact with the host environment while still running isolated.  
- **Persistent State**: Using Docker volumes, runner state, caches, and workflow artifacts can persist across container restarts.  

---

## Environment Variables

| Variable | Description |
| :------: | ----------- |
| REPO_URL* | The URL of the repository the runner will be active in. |
| RUNNER_TOKEN* | The token for the new runner, generated in GitHub for this repository. |
| RUNNER_NAME | The name for the new runner. Defaults to `Self-Hosted Github Runner`. |
| RUNNER_LABELS | Additional labels for the runner. `self-hosted` and `Linux` are always applied. |

*These variables are required for the runner to authenticate with GitHub and register itself.

---

## Features

- Runs GitHub Actions workflows triggered for your repository.
- Access to host Docker for integration testing or containerized services.
- Includes libraries required for .NET builds, graphics libraries (SkiaSharp / System.Drawing), and other common Linux dependencies.
- Non-root runner user with persistent workspace storage.
- Quick and consistent environment setup using Docker.
