# s6-aria2

A lightweight Aria2 Docker image based on Alpine Linux with s6-overlay.

[中文文档](README_zh.md)

## Features

- 🐳 **Lightweight** - Based on Alpine Linux, minimal image size
- 🔧 **Ready to Use** - Pre-configured with optimized Aria2 settings
- 🔄 **Auto Tracker Update** - Automatically updates BT tracker list
- 🏗️ **Multi-Architecture** - Supports amd64 and arm64
- 🔒 **Self-Contained** - All scripts bundled in image, no runtime downloads

## Quick Start

### Docker Run

```bash
docker run -d \
  --name aria2 \
  --network host \
  -e RPC_SECRET=your_password \
  -v ./config:/config \
  -v ./downloads:/downloads \
  hardbone12/s6-aria2
```

### Docker Compose

```yaml
services:
  s6-aria2:
    image: hardbone12/s6-aria2
    container_name: s6-aria2
    network_mode: host
    environment:
      - RPC_SECRET=your_password
      - RPC_PORT=6800
      - LISTEN_PORT=43318
      - UPDATE_TRACKERS=true
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    restart: unless-stopped
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RPC_SECRET` | (empty) | RPC access token |
| `RPC_PORT` | 6800 | RPC listen port |
| `LISTEN_PORT` | 43318 | BT listen port |
| `DISK_CACHE` | (empty) | Disk cache size, e.g., `64M` |
| `UPDATE_TRACKERS` | true | Auto-update BT trackers |
| `CUSTOM_TRACKER_URL` | (empty) | Custom tracker source URLs (appended to defaults) |
| `IPV6_MODE` | (empty) | IPv6 mode, `true` or `false` |
| `PUID` / `PGID` | (empty) | User/Group ID for running |
| `UMASK_SET` | 022 | File permission mask |

## Directory Structure

| Path | Description |
|------|-------------|
| `/config` | Configuration directory (persistent) |
| `/downloads` | Download directory (persistent) |
| `/config/aria2.conf` | Aria2 main config file |
| `/config/aria2.session` | Session file |

## Building

The project uses GitHub Actions for automated builds. Manual build steps:

```bash
# 1. Build s6-alpine base image
docker build -f Dockerfile-s6-alpine -t s6-alpine .

# 2. Build aria2 (takes ~20-40 minutes)
docker build -f Dockerfile-aria2-builder -t aria2-builder .
docker create --name tmp aria2-builder
mkdir -p ./aria2-bin/linux/amd64
docker cp tmp:/output/usr/bin/aria2c ./aria2-bin/linux/amd64/aria2c
docker rm tmp

# 3. Build main image
docker build --build-arg S6_ALPINE_IMAGE=s6-alpine -t s6-aria2 .
```

## Acknowledgements

- [aria2/aria2](https://github.com/aria2/aria2)
- [just-containers/s6-overlay](https://github.com/just-containers/s6-overlay)
- [P3TERX/Aria2-Pro-Docker](https://github.com/P3TERX/Aria2-Pro-Docker)
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg)
- [emikulic/darkhttpd](https://github.com/emikulic/darkhttpd)
- [ngosang/trackerslist](https://github.com/ngosang/trackerslist)
- [XIU2/TrackersListCollection](https://github.com/XIU2/TrackersListCollection)

## License

MIT License
