FROM busybox:latest AS extractor

# Download and extract the Terraria server
ADD https://terraria.org/system/dedicated_servers/archives/000/000/036/original/terraria-server-1402.zip /
RUN set -eux && \
    echo "0f01279b0b5def14f60985bc025302685f3e96bc1e647606acd6017946b91b49  terraria-server-1402.zip" | sha256sum -c && \
    mkdir /terraria_extracted && \
    unzip terraria-server-1402.zip -d /terraria_extracted && \
    rm terraria-server-1402.zip && \
    mv /terraria_extracted/1402/Linux /server && \
    chmod +x /server/TerrariaServer*

FROM debian:latest
# Note: All we need is a small image that has glibc and some basic tools, so bitnami/minideb
# would also work to save a few MB. This Dockerfile uses regular debian because it's an
# officially-supported image. Busybox-glibc doesn't work because it's missing librt.

ENV LANG C.UTF-8

# Create a "terraria" system user to run the game under,
# create a /data directory that the terraria user has access to,
# create a favorites.json to fix an error message.
RUN set -eux && \
    useradd -u 999 -rUms /usr/sbin/nologin terraria && \
    mkdir /data && chown -R terraria:terraria /data && \
    favorites_path="/home/terraria/My Games/Terraria" && \
    mkdir -p "$favorites_path" && chown -R terraria:terraria "$favorites_path" && \
    mkdir -p "$favorites_path" && \
    echo "{}" > "$favorites_path/favorites.json" && \
    chown terraria:terraria "$favorites_path/favorites.json"

COPY --chown=terraria:terraria --from=extractor /server /server

USER terraria
EXPOSE 7777
VOLUME ["/data"]
WORKDIR /server
ENTRYPOINT ["/server/TerrariaServer"]
CMD ["-x64", "-config", "/data/serverconfig.txt"]
