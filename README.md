# ComfyUI Docker Compose

Docker setup for running **ComfyUI** with Docker Compose.

**GitHub:** [pizano8080/comfyui_docker]


## Why This Docker Compose Setup Is Different

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

## Project Files

The project is divided into separate files so the Docker environment, persistent data, and ComfyUI installation can be managed independently.

| File                     | Description                                                                                                                                                                                                                                                                                                                                                                                                        |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `docker-compose.yml`     | Defines the ComfyUI container and its configuration. It maps the persistent workspace directories for ComfyUI, workflows, custom nodes, models, input, and output. It also controls GPU access, networking, ports, and container settings.                                                                                                                                                                         |
| `Dockerfile`             | Builds the basic Docker environment. It uses the Python Slim image as the base and installs the operating-system packages and build tools needed by ComfyUI and its dependencies. It does **not** contain the ComfyUI installation itself.                                                                                                                                                                         |
| `entrypoint.sh`          | Runs when the container starts and performs the ComfyUI installation. It downloads ComfyUI, installs its Python requirements, installs additional packages, and installs the configured custom nodes. The `REPOS` section can be modified to add additional custom nodes that should be installed automatically. The `.DONOTUPDATE` file prevents this installation process from running on every container start. |
| `extra_model_paths.yaml` | Optional ComfyUI configuration for additional model locations. Rename this file, for example to `extra_model_paths.yaml.disabled`, to prevent it from being installed into ComfyUI.                                                                                                                                                                                                                                |
| `README.md`              | Documentation for installing, configuring, updating, and maintaining this Docker setup.                                                                                                                                                                                                                                                                                                                            |



## Installation

### 1. Clone the repository

```bash
git clone https://github.com/pizano8080/comfyui_docker.git

cd comfyui_docker
```

### 2. First Run

For the first run, build and start the container with:

```bash
docker compose up -d --build
```

The first build may take some time.

### 3. Monitor the Build

Open **Docker Desktop**.

Find the `comfyui` container and select:

**⋮ → View details**

Use the logs to monitor the container startup and cache update.

Wait for the ComfyRegistry cache to finish updating. You should eventually see something similar to:

```text

    [INFO] Starting server


    [INFO] To see the GUI go to: http://0.0.0.0:8188
```

You can also check the logs from a command prompt/powershell/bash shell:

```bash
docker logs --tail 50 comfyui
```

## First-Time Setup

Once ComfyUI has finished starting:

1. Open ComfyUI.
2. Open **ComfyUI Manager**.
3. Select **Update All**.
4. Restart ComfyUI.
5. After restarting, use Manager to install any missing custom nodes.

## Starting ComfyUI

Once ComfyUI has been correctly installed and the container is working, use:

```bash
docker compose start
```

**Do not use `docker compose up -d` to simply start the existing container.**

`docker compose up -d` can remove and recreate the container. Since ComfyUI and its requirements are installed into the container rather than built into the image, the newly created container will only have the basic Docker image.

If the container has been recreated, you can force ComfyUI to be installed again by removing the `.DONOTUPDATE` file:

```bash
rm ../workspace/comfyui/.DONOTUPDATE
```

## Updating GitHub Files

Pull the latest files from GitHub:

```bash
git pull origin main
```

## Rebuilding

Rebuild when you want to update the **Docker and ComfyUI environment**, or when you change Docker installation files such as `Dockerfile` or `entrypoint.sh`.

Before rebuilding, remove the `.DONOTUPDATE` file:

```bash
rm ../workspace/comfyui/.DONOTUPDATE
```

Then rebuild and start the container:

```bash
docker compose up -d --build
```

Removing `.DONOTUPDATE` causes the entrypoint to download ComfyUI and reinstall the requirements after the rebuild.

### Import Failed Nodes

After running `docker compose up -d` or rebuilding the container, you might see **Import Failed** errors for some custom nodes.

If this occurs, open ComfyUI-Manager and use **Try Fix** on the affected nodes. This can resolve missing or incompatible Python dependencies without requiring changes to the Docker image.


## ComfyUI Database Initialization Issues

After some ComfyUI updates or rebuilds, you may occasionally encounter a **database initialization failure** when starting ComfyUI.

A simple workaround is to delete the ComfyUI database:

```bash
rm ../workspace/comfyui/user/comfyui.db
```

ComfyUI will create a new database when it starts.

**Warning:** Deleting the database removes settings and other information stored specifically in the ComfyUI database. Use this only as a workaround when the database cannot be initialized.


## Quick Maintenance

Update packages inside the running container:

```bash
docker exec comfyui sh -c "apt-get update && apt-get upgrade -y"
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

### Stop Docker Compose Container

```bash
docker compose stop
```

### Start Docker Compose Container

```bash
docker compose start
```

### Docker Cleanup

**Warning: THIS DELETES EVERYTHING THAT IS NOT RUNNING!!!!  BE VERY CAREFUL RUNNING THIS COMMAND!!!!!!**  This removes unused Docker images, containers, networks, and volumes. Make sure anything you want to keep is backed up before running this command.

```bash
docker system prune -a --volumes
```

## Known Issue with this install

### [ERROR] Failed to initialize database — `0008_drop_asset_meta` Database Error

Running **ComfyUI Manager → Update All** after a fresh install might cause this error:

```text
[ERROR] Failed to initialize database. Please ensure you have installed the latest requirements. If the error persists, please report this as in future the database will be required: Can't locate revision identified by '0008_drop_asset_meta'
```

This issue was **not occurring with other ComfyUI versions** and has been reproduced on a fresh installation using the current ComfyUI installation process.

### Recovery

If the error occurs after a fresh installation, or the ComfyUI database contents are not important, delete:

```text
/workspace/comfyui/user/comfyui.db
```

Then restart the ComfyUI container.

ComfyUI will automatically create a new `comfyui.db` database.

**Only `comfyui.db` needs to be deleted.** Do not delete the entire `user` directory.

The Docker installation starts and operates normally before the ComfyUI update. The database error occurs after using **ComfyUI Manager → Update All** for the first time.

