FROM diyagi/steamcmd-wine:root-noble AS base-steamcmd-wine

LABEL maintainer="github@diyagi.dev" \
      name="diyagi/abioticfactor-server-docker" \
      github="https://github.com/Diyagi/abioticfactor-server-docker" \
      dockerhub="https://hub.docker.com/r/diyagi/abioticfactor-server-docker" \
      org.opencontainers.image.authors="Diyagi" \
      org.opencontainers.image.source="https://github.com/Diyagi/abioticfactor-server-docker"

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    tzdata \
    gosu \
    tini \
    jo \
    gettext-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
ENV STEAMAPPID=427410
ENV STEAMDEDICATEDAPPID=2857200
ENV STEAMAPP "abiotic-factor"
ENV STEAMAPPSERVER "/${STEAMAPP}"
ENV SAVEDATA "${STEAMAPPSERVER}/AbioticFactor/Saved/SaveGames/Server"
ENV SCRIPTSDIR="${HOMEDIR}/scripts"

# Setup folders
COPY ./scripts ${SCRIPTSDIR}
RUN set -x \
    && chmod +x -R "${SCRIPTSDIR}" \
    && mkdir -p "${STEAMAPPSERVER}" \
    && chown -R "${USER}:${USER}" "${SCRIPTSDIR}" "${STEAMAPPSERVER}" \
    && mkdir /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && chown root /tmp/.X11-unix

ENV PUID=1000 \
    PGID=1000 \
    GSMAXSERVERPLAYERS=6 \
    GSPORT=7777 \
    GSQUERYPORT=27015 \
    GSWORLDSAVENAME="" \
    GSSERVERPASSWORD="" \
    GSSERVERNAME="Abiotic Factor Docker" \
    DISCORD_WEBHOOK_URL="" \
    # Server Start
    DISCORD_SERVER_START_ENABLED=true \
    DISCORD_SERVER_START_MESSAGE='**World:** ${world_name}\n**Short Code:** ${short_code}' \
    DISCORD_SERVER_START_TITLE="Server Started" \
    DISCORD_SERVER_START_COLOR="2013440" \
    # Server Stop
    DISCORD_SERVER_STOP_ENABLED=true \
    DISCORD_SERVER_STOP_MESSAGE="" \
    DISCORD_SERVER_STOP_TITLE="Server Stopped" \
    DISCORD_SERVER_STOP_COLOR="12779520" \
    # Chat Log
    DISCORD_CHAT_LOG_ENABLED=true \
    DISCORD_CHAT_LOG_COLOR="16777215"

# Switch to workdir
WORKDIR ${HOMEDIR}

# Use tini as the entrypoint for signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["bash", "scripts/entry.sh"]
