\# ComfyUI Docker



Docker setup for running \*\*ComfyUI\*\* with Docker Compose.



\*\*GitHub:\*\* \[pizano8080/comfyui_docker]



\## Installation



\### 1. Clone the repository



```bash

git clone https://github.com/pizano8080/comfyui_docker.git

cd comfyui_docker

```



\### 2. Build and start ComfyUI



```bash

docker compose up -d --build

```



The first build may take some time.



\### 3. Monitor the build



Open \*\*Docker Desktop\*\*.



Find the `comfyui` container and select:



\*\*⋮ → View details\*\*



Use the logs to monitor the container startup and cache update.



Wait for the ComfyRegistry cache to finish updating. You should eventually see something similar to:


  FETCH ComfyRegistry Data: 160/164
  
  FETCH ComfyRegistry Data \[DONE]
  
  [INFO] [ComfyUI-Manager] default cache updated: https://api.comfy.org/nodes
  


You can also check the logs from a command prompt/powershell/bash shell:



```bash

docker logs --tail 50 comfyui

```



\## First-Time Setup



Once ComfyUI has finished starting:



1\. Open ComfyUI.

2\. Open \*\*ComfyUI Manager\*\*.

3\. Select \*\*Update All\*\*.

4\. Restart ComfyUI.

5\. After restarting, use Manager to install any missing custom nodes.



\## Updating



Pull the latest files from GitHub:



```bash

git pull origin main

```



If the Docker files changed, rebuild the container:



```bash

docker compose up -d --build

```



\## Quick Maintenance



Update packages inside the running container:



```bash

docker exec comfyui sh -c "apt-get update && apt-get upgrade -y"

```



\## Full Refresh



Pull the latest Docker base images and rebuild:



```bash

docker compose build --pull

docker compose up -d

```



\## Docker Cleanup



\*\*Warning:\*\* This removes unused Docker images, containers, networks, and volumes. Make sure anything you want to keep is backed up before running this command.



```bash

docker system prune -a --volumes

```



\## Useful Commands



\### View recent logs



```bash

docker logs --tail 50 comfyui

```



\### Follow logs live



```bash

docker logs -f comfyui

```



\### Check running containers



```bash

docker ps

```



\### Stop ComfyUI



```bash

docker compose down

```



\### Start ComfyUI



```bash

docker compose up -d

```



