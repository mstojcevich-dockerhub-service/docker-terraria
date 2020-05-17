# Terraria Docker Image

Small Docker image for the vanilla Terraria 1.4.0.2 server.

## Usage

This image expects a volume mounted to `/data` to store stuff like the server config and world data. By default, this container does not run as root; because of this, the `/data` directory must be readable/writeable by uid 999 (the 'terraria' user within the container). To change the uid that the server runs as, pass a custom `--user` to `docker run`.

The default config location is `/data/serverconfig.txt`.

Here's an example of running a Terraria server using this image:
```
docker run -it \
  -p 7777:7777 \
  -v /mnt/storage/my_terraria_server:/data \
  --name=my_terraria_server \
  mstojcevich/docker-terraria:latest
```

Note that Terraria requires a TTY, so `-t` must be passed to `docker run` even when running daemonized.