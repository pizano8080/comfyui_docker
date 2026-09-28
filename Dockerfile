FROM python:3.13-slim-trixie

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      build-essential \
      cmake \
      ninja-build \
      libgl1 \
      libglx-mesa0 \
      libglib2.0-0 \
      fonts-dejavu-core \
      fontconfig \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY extra_model_paths.yaml /app/extra_model_paths.yaml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8188

ENTRYPOINT ["/entrypoint.sh"]
