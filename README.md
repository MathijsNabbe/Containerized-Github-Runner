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

## Tested Actions
### Dotnet
| Action | NET10.0 |
| ------ | :-----: |
| .NET Build | :white_check_mark: |
| .NET Test | :white_check_mark: |
| SonarQube Analysis | :white_check_mark: |
| Docker Image Build | :white_check_mark: |

### Kotlin
| Action | Android 35 SDK |
| ------ | :------------: |
| Kotlin Build | :white_check_mark: |
| SonarQube Analysis | :white_check_mark: |

## Installation Guide (Linux)
### 1. Open a terminal / SSH into your Docker host. 
Make sure you’re on the machine where Docker Engine is running and where you want to run the GitHub runner.

### 2. Clone your repository.
```bash
git clone git@github.com:MathijsNabbe/Containerized-Github-Runner.git
```
Replace the URL with your repo’s actual HTTPS or SSH URL.

### 3. Navigate into the repo folder.
```bash
cd Containerized-Github-Runner
```
Make sure this folder contains your Dockerfile and your docker-compose.yml.

### 4. Build the Docker image locally.
This step builds your GitHub runner image using the Dockerfile.
```bash
docker build -t github-runner:local .
```
* `-t github-runner:local` tags the image as `github-runner:local`.
* The `.` means build context is current directory (the root of the repo).
You should see output with build steps and finally:
```bash
Successfully built <image-id>
Successfully tagged github-runner:local
```

### 5. Edit your `docker-compose.yml`.
The image rquires a set of environment variables to be set. Open the docker compose file and overwrite the environment variables:
```yaml
REPO_URL: "https://github.com/user/repo"
RUNNER_TOKEN: "insert_token_here"
RUNNER_NAME: "insert_token_here" # optional
RUNNER_LABELS: "label1,label2" # optional
```

### 6. Start the docker container.
```bash
docker compose up -d
```
