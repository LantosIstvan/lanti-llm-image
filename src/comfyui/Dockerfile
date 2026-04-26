ARG VERSION_PYTHON
FROM python:${VERSION_PYTHON}

LABEL maintainer="lantosistvan89@gmail.com"

ARG COMFYUI_DIR="/usr/src/ComfyUI"
ARG COMFYUI_MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-manager"
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
	### Workflow
	&& mkdir -p ${COMFYUI_SEEDVR2_DIR} \
		&& git clone --branch main --single-branch "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git" ${COMFYUI_SEEDVR2_DIR} \
		# && mkdir -p ${COMFYUI_FLORENCE2_DIR} \
	# 	&& git clone --branch main --single-branch "https://github.com/kijai/ComfyUI-Florence2.git" ${COMFYUI_FLORENCE2_DIR} \
	# && mkdir -p ${COMFYUI_TENSOROPS_DIR} \
	# 	&& git clone --branch main --single-branch "https://github.com/un-seen/comfyui-tensorops.git" ${COMFYUI_TENSOROPS_DIR} \
	&& pip install --upgrade pip \
    && pip install --upgrade \
		torch \
		torchaudio \
		torchvision \
    		--index-url "https://download.pytorch.org/whl/cu130" \
			--prefer-binary \
    && pip install --upgrade \
        xformers \
        	--index-url "https://download.pytorch.org/whl/cu130" \
			--prefer-binary \
    && pip install -r "${COMFYUI_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_MANAGER_DIR}/requirements.txt" \
	&& pip install -r "${COMFYUI_MEMORY_CLEANUP_DIR}/requirements.txt" \
	### Workflow
	&& pip install -r "${COMFYUI_SEEDVR2_DIR}/requirements.txt" \
		# && pip install --upgrade \
		# 	diffusers \
		# 	transformers \
	# && pip install -r "${COMFYUI_FLORENCE2_DIR}/requirements.txt" \
	# && pip install -r "${COMFYUI_TENSOROPS_DIR}/requirements.txt" \
    # Felesleges fájlok agresszív törlése a rétegből
    && find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
	### Cleanup
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# TCMalloc aktiválása (memória optimalizációhoz)
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# https://github.com/comfyanonymous/ComfyUI/blob/master/comfy/cli_args.py
CMD ["python3", "./main.py", "--listen", "--preview-method", "auto", "--cache-none"]
