ARG VERSION_PYTHON
FROM python:${VERSION_PYTHON}

LABEL maintainer="lantosistvan89@gmail.com"

# Átvehető UID és GID a host gépről (jogosultsági problémák elkerülésére)
ARG UID=1000
ARG GID=1000

ARG COMFYUI_DIR="/usr/src/ComfyUI"
ARG COMFYUI_MEMORY_CLEANUP_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-memory-cleanup"
### Workflow
ARG COMFYUI_SEEDVR2_DIR="${COMFYUI_DIR}/custom_nodes/seedvr2_videoupscaler"
# ARG COMFYUI_FLORENCE2_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-florence2"
# ARG COMFYUI_TENSOROPS_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-tensorops"

ENV NODE_ENV="production"
# Ne írjon .pyc fájlokat a lemezre futás közben (tárhely spórolás)
ENV PYTHONDONTWRITEBYTECODE=1

# PIP globális beállításai
ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_NO_CACHE_DIR=1

# VIRTUAL ENV beállítása (a PATH frissítésével minden python és pip parancs ide fog mutatni)
ENV VIRTUAL_ENV="${COMFYUI_DIR}/venv"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# TCMalloc aktiválása (memória optimalizációhoz)
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"

# ENTRYPOINT másolása root-ként a jogosultságok beállítása miatt
COPY docker-entrypoint.sh /usr/local/bin/

# ROOT LÉPÉSEK: Csomagok telepítése, felhasználó létrehozása, sudo jogkör kiosztása, mappajogok
RUN set -e \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        git-lfs \
        google-perftools \
        libgl1 \
        libglib2.0-0 \
        libgoogle-perftools-dev \
        libtcmalloc-minimal4 \
        wget \
        sudo \
    && groupadd --gid $GID comfyuser \
    && useradd --gid comfyuser --create-home --shell /bin/sh --uid $UID comfyuser \
    && echo "comfyuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/comfyuser \
    && chmod 0440 /etc/sudoers.d/comfyuser \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p ${COMFYUI_DIR} \
    && chown -R comfyuser:comfyuser ${COMFYUI_DIR} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Váltás a létrehozott felhasználóra
USER comfyuser
WORKDIR ${COMFYUI_DIR}

# USER LÉPÉSEK: Forráskód letöltése, VENV létrehozása és csomagok telepítése a felhasználó nevében
RUN set -e \
    && git clone --branch master --single-branch "https://github.com/comfyanonymous/ComfyUI.git" ${COMFYUI_DIR} \
    && mkdir -p ${COMFYUI_MEMORY_CLEANUP_DIR} \
        && git clone --branch main --single-branch "https://github.com/LAOGOU-666/Comfyui-Memory_Cleanup.git" ${COMFYUI_MEMORY_CLEANUP_DIR} \
    ### Workflow
    && mkdir -p ${COMFYUI_SEEDVR2_DIR} \
        && git clone --branch main --single-branch "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git" ${COMFYUI_SEEDVR2_DIR} \
	# && mkdir -p ${COMFYUI_FLORENCE2_DIR} \
	# 	&& git clone --branch main --single-branch "https://github.com/kijai/ComfyUI-Florence2.git" ${COMFYUI_FLORENCE2_DIR} \
	# && mkdir -p ${COMFYUI_TENSOROPS_DIR} \
	# 	&& git clone --branch main --single-branch "https://github.com/un-seen/comfyui-tensorops.git" ${COMFYUI_TENSOROPS_DIR} \
    ### Python venv létrehozása a user jogkörével
    && python3 -m venv ${VIRTUAL_ENV} \
    ### Csomagok telepítése a venv-be
    && pip install --upgrade pip \
    && pip install --upgrade \
        torch \
        torchaudio \
        torchvision \
            --extra-index-url "https://download.pytorch.org/whl/cu130" \
            --prefer-binary \
    && pip install --upgrade \
        xformers \
            --index-url "https://download.pytorch.org/whl/cu130" \
            --prefer-binary \
    && pip install -r "${COMFYUI_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_DIR}/manager_requirements.txt" \
    && pip install -r "${COMFYUI_MEMORY_CLEANUP_DIR}/requirements.txt" \
    ### Workflow
    && pip install -r "${COMFYUI_SEEDVR2_DIR}/requirements.txt" \
	# && pip install -r "${COMFYUI_FLORENCE2_DIR}/requirements.txt" \
	# && pip install -r "${COMFYUI_TENSOROPS_DIR}/requirements.txt" \
    # Felesleges fájlok agresszív törlése a rétegből
    && find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

ENTRYPOINT ["docker-entrypoint.sh"]

# A venv miatt a rendszer automatikusan a környezeti python3-at fogja használni
CMD ["python3", "./main.py", "--listen", "--preview-method", "auto", "--cache-none", "--enable-manager"]
