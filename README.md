\# create a docker compose folder for install files

mkdir comfyui-docker

\# unzip/copy all of the install files inside folder you created

cd comfyui-docker

docker compose up -d --build

\# wait for container to build

open docker desktop

press triple dots and press view details to watch logs

\# wait for cache to update

&#x20;    # should see something like below when cache is rebuilt and completed

&#x20;    FETCH ComfyRegistry Data: 160/164

&#x20;    FETCH ComfyRegistry Data \[DONE]

&#x20;    \[INFO] \[ComfyUI-Manager] default cache updated: https://api.comfy.org/nodes

\# command to check logs at cmd prompt

docker logs --tail 50 comfyui

Open Comfyui

Open Manager

Press Update All in menu.

Restart

after restart use Manager to Install any missing nodes





\#Quick maintenance:

docker exec comfyui sh -c "apt-get update \&\& apt-get upgrade -y"



\#Full refresh:

docker compose build --pull

docker compose up -d

&#x20;



\#purge (make sure what you want to keep is running):

docker system prune -a --volumes

