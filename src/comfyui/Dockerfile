ARG VERSION_PYTHON
FROM python:${VERSION_PYTHON}

LABEL maintainer="lantosistvan89@gmail.com"

ARG COMFYUI_DIR
ARG COMFYUI_MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-manager"
ARG COMFYUI_MEMORY_CLEANUP_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-memory-cleanup"
ENV NODE_ENV="production"

RUN mkdir -p ${COMFYUI_DIR}
WORKDIR ${COMFYUI_DIR}

RUN set -e \
	&& apt update \
	&& apt install -y --no-install-recommends \
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
	&& pip install --pre --upgrade \
		torch==2.8.0 \
		torchaudio==2.8.0 \
		torchvision==0.23 \
			--extra-index-url "https://download.pytorch.org/whl/nightly/cu129" \
			--prefer-binary \
	&& pip install --upgrade  \
		xformers==0.0.32.post2 \
			--extra-index-url "https://download.pytorch.org/whl/cu128" \
			--prefer-binary \
	&& pip install -r "${COMFYUI_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_MANAGER_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_MEMORY_CLEANUP_DIR}/requirements.txt" \
	### Cleanup
	&& rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# https://github.com/comfyanonymous/ComfyUI/blob/master/comfy/cli_args.py
CMD ["python3", "./main.py", "--listen", "--preview-method", "auto", "--cache-none"]
