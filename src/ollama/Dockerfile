# syntax=docker/dockerfile:1

ARG VERSION_OLLAMA=latest
FROM ollama/ollama:${VERSION_OLLAMA}

LABEL maintainer="lantosistvan89@gmail.com"

# RUN set -e \
# 	&& apt update \
# 	&& apt install -y --no-install-recommends \
# 		curl \
# 	&& rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
