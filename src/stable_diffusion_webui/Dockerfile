# syntax=docker/dockerfile:1

ARG VERSION_DEBIAN
FROM debian:${VERSION_DEBIAN}

LABEL maintainer="lantosistvan89@gmail.com"

ARG UID
ARG GID

ENV APP_DIR="/usr/src/webui"

RUN set -e \
	&& groupadd --gid $GID sduser \
	&& useradd --gid sduser --create-home --shell /bin/sh --uid $UID sduser \
	&& apt update \
	&& apt install -y --no-install-recommends \
		ca-certificates \
		git \
		git-lfs \
		google-perftools \
		libgl1 \
		libglib2.0-0 \
		python3 \
		python3-pip \
		python3-venv \
		wget \
		# libtcmalloc-minimal4 \
		# sudo \
	&& mkdir -p ${APP_DIR} \
		&& git clone "https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" ${APP_DIR} \
	&& chown -R sduser:sduser ${APP_DIR} \
	&& rm -rf /var/lib/apt/lists/*

USER sduser

WORKDIR ${APP_DIR}

RUN set -e \
	&& git checkout release_candidate \
	&& python3 -m venv ./venv \
	&& . ./venv/bin/activate \
	&& pip install --upgrade pip \
	&& pip install \
		numpy \
		torch \
		torchvision \
		torchaudio \
			--extra-index-url "https://download.pytorch.org/whl/cu128" \
			--prefer-binary \
	&& pip install \
		xformers \
			--extra-index-url "https://download.pytorch.org/whl/cu128" \
			--prefer-binary \
	&& pip install "https://github.com/openai/CLIP/archive/refs/heads/main.zip" --prefer-binary \
	&& pip install -r ./requirements.txt \
	&& mkdir -p \
		${APP_DIR}/models \
		${APP_DIR}/outputs \
		${APP_DIR}/repositories

### Additional models
### https://openmodeldb.info/
### https://civitai.com/

### Activate virtual environment
### https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV VIRTUAL_ENV="${APP_DIR}/venv"
ENV _OLD_VIRTUAL_PATH="$PATH"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN unset PYTHONHOME

# https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Command-Line-Arguments-and-Settings
# ENV COMMANDLINE_ARGS="--api --enable-console-prompts --enable-insecure-extension-access --listen --medvram --no-download-sd-mode --theme=dark --xformers"
ENV COMMANDLINE_ARGS="--api --enable-console-prompts --enable-insecure-extension-access --listen --medvram --theme=dark --xformers"
# ENV COMMANDLINE_ARGS="--api --listen --xformers --enable-insecure-extension-access --theme=dark --sd-checkpoint sd3.5_medium.safetensors --vae-path sdxl_vae.safetensors"
ENV NODE_ENV="production"

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["python3", "./launch.py"]
