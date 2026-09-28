#!/usr/bin/env bash

set -e

COMFY_DIR=/app/ComfyUI
TEMP_DIR=/tmp/ComfyUI

UPDATE_MARKER="$COMFY_DIR/.DONOTUPDATE"
CN_DIR="$COMFY_DIR/custom_nodes"


# OLD Custom Node - ["ComfyUI_UltimateSDUpscale"]="https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"
# OLD Custom Node - ["ComfyUI_essentials"]="https://github.com/cubiq/ComfyUI_essentials.git"
# OLD Custom Node - ["ComfyUI-Crystools"]="https://github.com/crystian/ComfyUI-Crystools.git"

declare -A REPOS=(

["ComfyUI-Manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"

["rgthree-comfy"]="https://github.com/rgthree/rgthree-comfy.git"

["ComfyUI-KJNodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"

)



if [ ! -f "$UPDATE_MARKER"  ]; then

    echo "=== Installing ComfyUI ==="

    rm -rf "$TEMP_DIR"

    git clone \
      https://github.com/comfyanonymous/ComfyUI.git \
      "$TEMP_DIR"

    cp -a "$TEMP_DIR/." "$COMFY_DIR/"

    rm -rf "$TEMP_DIR"


    MODEL_SOURCE="$COMFY_DIR/models"
    MODEL_TARGET="/models"

    if [ -d "$MODEL_SOURCE" ]; then
        echo "=== Checking model directories ==="

        while IFS= read -r -d '' dir; do
            relative="${dir#"$MODEL_SOURCE"/}"
            target="$MODEL_TARGET/$relative"

            if [ ! -d "$target" ]; then
                echo "Creating model directory: $relative"
                mkdir -p "$target"
            fi
        done < <(find "$MODEL_SOURCE" -mindepth 1 -type d -print0)
    fi

    cd "$COMFY_DIR"

    echo "=== Installing ComfyUI requirements ==="

    pip install --upgrade pip

    pip install \
      -r requirements.txt
	  
    pip install torchaudio
    pip install sageattention
    pip install sqlalchemy

    if [ -e /dev/kfd ]; then
        echo "=== AMD ROCm GPU detected ==="

        ROCM_VERSION=$(python -c "import urllib.request,re; s=urllib.request.urlopen('https://download.pytorch.org/whl/').read().decode(); v=re.findall(r'href=\"(rocm[0-9.]+)/\"',s); print(sorted(set(v),key=lambda x:tuple(map(int,x[4:].split('.'))))[-1])")

        echo "=== Latest ROCm wheel: $ROCM_VERSION ==="

        pip uninstall -y torch torchvision torchaudio

        pip install torch torchvision torchaudio \
          --index-url "https://download.pytorch.org/whl/$ROCM_VERSION"
    fi


    mkdir -p "$CN_DIR"

    echo "=== Installing custom nodes ==="

    for name in "${!REPOS[@]}"; do

        target="$CN_DIR/$name"

        if [ ! -d "$target" ]; then
            git clone \
              "${REPOS[$name]}" \
              "$target"
        fi

        if [ -f "$target/requirements.txt" ]; then

            pip install \
              -r "$target/requirements.txt"

        fi

    done


    touch "$UPDATE_MARKER"

fi


if [ -f /app/extra_model_paths.yaml ] && [ ! -f "$COMFY_DIR/extra_model_paths.yaml" ]; then
    echo "=== Installing extra_model_paths.yaml ==="
    cp /app/extra_model_paths.yaml "$COMFY_DIR/extra_model_paths.yaml"
fi


echo "=== Starting ComfyUI ==="

exec "$@"
