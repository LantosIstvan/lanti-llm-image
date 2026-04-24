ARG VERSION_PYTHON
FROM python:${VERSION_PYTHON}

LABEL maintainer="lantosistvan89@gmail.com"

ARG COMFYUI_DIR="/usr/src/ComfyUI"
ARG COMFYUI_MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-manager"
ARG COMFYUI_MEMORY_CLEANUP_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-memory-cleanup"

ENV NODE_ENV="production"
# TCMalloc aktiválása (memória optimalizációhoz)
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
# Ne írjon .pyc fájlokat a lemezre futás közben (tárhely spórolás)
ENV PYTHONDONTWRITEBYTECODE=1

RUN mkdir -p ${COMFYUI_DIR}
WORKDIR ${COMFYUI_DIR}

RUN set -e \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
		git \
		git-lfs \
		google-perftools \
		libgl1 \
		libglib2.0-0 \
		libgoogle-perftools-dev \
		libtcmalloc-minimal4 \
		wget \
    && git clone --branch master --single-branch "https://github.com/comfyanonymous/ComfyUI.git" ${COMFYUI_DIR} \
	&& mkdir -p ${COMFYUI_MANAGER_DIR} \
		&& git clone --branch main --single-branch "https://github.com/Comfy-Org/ComfyUI-Manager.git" ${COMFYUI_MANAGER_DIR} \
	&& mkdir -p ${COMFYUI_MEMORY_CLEANUP_DIR} \
		&& git clone --branch main --single-branch "https://github.com/LAOGOU-666/Comfyui-Memory_Cleanup.git" ${COMFYUI_MEMORY_CLEANUP_DIR} \
	&& pip install --upgrade pip \
    && pip install -v --pre --upgrade --no-cache-dir \
		torch \
		torchaudio \
		torchvision \
    		--extra-index-url "https://download.pytorch.org/whl/nightly/cu132" \
			--prefer-binary \
    && pip install -v --pre --upgrade --no-cache-dir \
        xformers \
        	--extra-index-url "https://download.pytorch.org/whl/nightly/cu132" \
			--prefer-binary \
    && pip install -r "${COMFYUI_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_MANAGER_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_MEMORY_CLEANUP_DIR}/requirements.txt" \
    # Felesleges fájlok agresszív törlése a rétegből
    && find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
	### Cleanup
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# https://github.com/comfyanonymous/ComfyUI/blob/master/comfy/cli_args.py
CMD ["python3", "./main.py", "--listen", "--preview-method", "auto", "--cache-none"]
