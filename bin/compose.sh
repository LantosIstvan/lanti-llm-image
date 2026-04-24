#!/bin/sh
set -e

DIR=$( cd "$(dirname $0)" && pwd )
. $DIR/env_variables.sh

usage_fn() {
	cat <<- EOF
	#########################################################
	Run Docker Compose project
		Usage: $0 up|down|prune|bootstrap

		Commands:
			up:          Start Docker Compose project
			down:        Stop and remove containers, networks
			prune:       Remove everything
			bootstrap:   Bootstrapping WSL2 environment
	#########################################################
	EOF
}

up_fn() {
	echo "Start Docker Compose project"
	docker compose \
		--env-file $ABS_PATH/.env \
		--file $ABS_PATH/compose.yaml \
		--profile cache \
		pull
	docker compose \
		--env-file $ABS_PATH/.env \
		--file $ABS_PATH/compose.yaml \
		$SERVICES \
		up --detach
}

down_fn() {
	echo "Stop and remove containers, networks"
	docker compose \
		--env-file $ABS_PATH/.env \
		--file $ABS_PATH/compose.yaml \
		$SERVICES \
		down
}

prune_fn() {
	echo "Prune everything"
	echo "Remove all containers"
		docker container stop $(docker container ls --all --quiet) 2>/dev/null || true
		docker container prune --force
	echo "Remove all unused networks"
		docker network prune --force
	echo "Remove unused images"
		docker image prune --all --force
}

cleanup_fn() {
	echo "Cleanup Docker leftovers"
	echo "Remove all unused data"
		docker system prune --all --force --volumes
	echo "Remove build cache"
		docker builder prune --all --force
}

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#with-apt-ubuntu-debian
# https://github.com/NVIDIA/nvidia-container-toolkit/releases
bootstrap_fn() {
	if [ "$(id -u)" -ne 0 ]; then
		echo "Requires root privilege. It will be executed with sudo..." >&2
		sudo "$0" "$@"
		exit $?
	fi

	echo "Bootstrap: WSL2 environment setup with NVIDIA GPU support..."

	echo "[1/6] Install the prerequisites"
	apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		gnupg2

	echo "[2/6] Configure the production repository"
	curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
		&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
		sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
		tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

	echo "[3/6] Update the packages list from the repository"
	apt-get update

	echo "[4/6] Install the NVIDIA Container Toolkit packages"
	export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.19.0-1
	sudo apt-get install -y \
		nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
		nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
		libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
		libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

	echo "[5/6] Configure the container runtime"
	nvidia-ctk runtime configure --runtime=docker

	echo "[6/6] Configure KVM utilities"
	apt-get install -y --no-install-recommends \
		cpu-checker

	# Verify
	# docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi

	echo "✅ BOOTSTRAP FINISHED!\n\n🔴 IMPORTANT LAST STEP:\nRestart Docker Desktop to apply the changes!"
}

if [ $# -eq 0 ]; then
	usage_fn
	exit 1
fi

case "$1" in
	up)
		up_fn
		;;
	down)
		down_fn
		;;
	prune)
		down_fn
		prune_fn
		cleanup_fn
		;;
	bootstrap)
		bootstrap_fn "$@"
		;;
	*)
		usage_fn
		echo "$0: unknown argument provided => $1\n"
		exit 1
		;;
esac
