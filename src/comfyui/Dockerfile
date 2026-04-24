ARG VERSION_PYTHON
FROM python:${VERSION_PYTHON}

LABEL maintainer="lantosistvan89@gmail.com"

ARG UID=1000
ARG GID=1000

ARG COMFYUI_DIR="/usr/src/ComfyUI"
ARG COMFYUI_MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-manager"
ARG COMFYUI_MEMORY_CLEANUP_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-memory-cleanup"

ENV NODE_ENV="production"
# TCMalloc aktiválása (memória optimalizációhoz)
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
# Ne írjon .pyc fájlokat a lemezre futás közben (tárhely spórolás)
ENV PYTHONDONTWRITEBYTECODE=1

# Rendszerfüggőségek telepítése és User létrehozása (Root-ként)
RUN set -e \
    && groupadd --gid ${GID} comfyuser \
    && useradd --gid comfyuser --create-home --shell /bin/sh --uid ${UID} comfyuser \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
		git-lfs \
		google-perftools \
		libgl1 \
		libglib2.0-0 \
		libtcmalloc-minimal4 \
		wget \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${COMFYUI_DIR} \
    && chown -R comfyuser:comfyuser ${COMFYUI_DIR}

USER comfyuser
WORKDIR ${COMFYUI_DIR}

ENV VIRTUAL_ENV="${COMFYUI_DIR}/venv"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Alkalmazás telepítése egyetlen hatalmas, optimalizált rétegben
RUN set -e \
    # ELŐSZÖR a ComfyUI klónozása (mivel a '.' célkönyvtárnak üresnek kell lennie)
    && git clone --depth 1 --branch master --single-branch "https://github.com/comfyanonymous/ComfyUI.git" . \
    \
    # UTÁNA a Venv létrehozása a már meglévő (klónozott) mappába
    && python3 -m venv ${VIRTUAL_ENV} \
    && pip install --no-cache-dir --upgrade pip \
    \
    # Custom node-ok klónozása
    && mkdir -p ${COMFYUI_MANAGER_DIR} \
    && git clone --depth 1 --branch main --single-branch "https://github.com/Comfy-Org/ComfyUI-Manager.git" ${COMFYUI_MANAGER_DIR} \
    && mkdir -p ${COMFYUI_MEMORY_CLEANUP_DIR} \
    && git clone --depth 1 --branch main --single-branch "https://github.com/LAOGOU-666/Comfyui-Memory_Cleanup.git" ${COMFYUI_MEMORY_CLEANUP_DIR} \
    \
    # PyTorch és Xformers telepítése
    && pip install --pre --no-cache-dir \
		torch \
		torchaudio \
		torchvision \
    		--index-url "https://download.pytorch.org/whl/nightly/cu132" \
			--prefer-binary \
    && pip install --pre --no-cache-dir \
        xformers \
        	--index-url "https://download.pytorch.org/whl/nightly/cu132" \
			--prefer-binary \
    \
    # Függőségek telepítése
    && pip install --no-cache-dir -r requirements.txt \
	&& pip install --no-cache-dir sqlalchemy alembic \
    && pip install --no-cache-dir -r "${COMFYUI_MANAGER_DIR}/requirements.txt" \
    && pip install --no-cache-dir -r "${COMFYUI_MEMORY_CLEANUP_DIR}/requirements.txt" \
    \
    # Felesleges fájlok agresszív törlése a rétegből
    && find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

USER root
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
USER comfyuser

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["python3", "./main.py", "--listen", "0.0.0.0", "--preview-method", "auto", "--cache-none"]
