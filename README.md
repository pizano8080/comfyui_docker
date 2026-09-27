# ComfyUI Docker

Docker setup for running **ComfyUI** with Docker Compose.

**GitHub:** [pizano8080/comfyui_docker]

## Installation

### 1. Clone the repository

```bash

git clone https://github.com/pizano8080/comfyui_docker.git

cd comfyui_docker

```

### 2. Build and start ComfyUI

```bash

docker compose up -d --build

```

The first build may take some time.

### 3. Monitor the build

Open **Docker Desktop**.

Find the `comfyui` container and select:

**⋮ → View details**

Use the logs to monitor the container startup and cache update.

Wait for the ComfyRegistry cache to finish updating. You should eventually see something similar to:

```text
FETCH ComfyRegistry Data: 160/164
FETCH ComfyRegistry Data [DONE]
[INFO] [ComfyUI-Manager] default cache updated: https://api.comfy.org/nodes
```

You can also check the logs from a command prompt/powershell/bash shell:

```bash

docker logs --tail 50 comfyui

```

## Why This Docker Setup Is Different

Traditional Docker deployments typically put the application and its dependencies directly into the Docker image:

```text
Docker Image
├── OS / Runtime
├── ComfyUI
├── Python dependencies
└── Custom nodes
```

This works well for applications that change relatively infrequently. However, **ComfyUI and its custom-node ecosystem change frequently**, with new versions, dependencies, and compatibility updates appearing regularly.

This project takes a different approach:

```text
Docker Image
├── OS / Runtime
├── Build tools
└── Startup environment

Persistent Workspace
├── ComfyUI
├── Custom nodes
├── Workflows
└── Models
```

The container provides the environment needed to run ComfyUI, while the actual ComfyUI installation and user data are kept in persistent workspace directories.

On a fresh installation, the startup script downloads the current ComfyUI version and installs its requirements and configured custom nodes. Once installed, the `.DONOTUPDATE` marker prevents the installation process from running again on every container restart.

This approach means there is **no large ComfyUI Docker image to maintain**. Instead of rebuilding and publishing an image whenever ComfyUI or its dependencies change, the setup can install the current versions when a fresh environment is created.

The tradeoff is that a fresh installation takes longer than starting an already-built application image. For ComfyUI, this is intentional: the goal is to keep the Docker image simple while making the ComfyUI installation flexible and easy to refresh.

## First-Time Setup

Once ComfyUI has finished starting:

1. Open ComfyUI.
2. Open **ComfyUI Manager**.
3. Select **Update All**.
4. Restart ComfyUI.
5. After restarting, use Manager to install any missing custom nodes.

## Updating

Pull the latest files from GitHub:

```bash

git pull origin main

```

If the Docker files changed, rebuild the container:

```bash

docker compose up -d --build

```

## Quick Maintenance

Update packages inside the running container:

```bash

docker exec comfyui sh -c "apt-get update && apt-get upgrade -y"

```

## Full Refresh

Pull the latest Docker base images and rebuild:

```bash

docker compose build --pull

docker compose up -d

```

## Docker Cleanup

**Warning:** This removes unused Docker images, containers, networks, and volumes. Make sure anything you want to keep is backed up before running this command.

```bash

docker system prune -a --volumes

```

## Useful Commands

### View recent logs

```bash

docker logs --tail 50 comfyui

```

### Follow logs live

```bash

docker logs -f comfyui

```

### Check running containers

```bash

docker ps

```

### Stop ComfyUI

```bash

docker compose down

```

### Start ComfyUI

```bash

docker compose up -d

```
