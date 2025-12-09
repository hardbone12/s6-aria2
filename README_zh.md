# s6-aria2

基于 Alpine Linux + s6-overlay 的轻量级 Aria2 Docker 镜像。

## 特性

- 🐳 **轻量级** - 基于 Alpine Linux，镜像体积小
- 🔧 **开箱即用** - 预置优化的 Aria2 配置
- 🔄 **自动更新 Tracker** - 支持自动更新 BT Tracker 列表
- 🏗️ **多架构支持** - 支持 amd64 和 arm64
- 🔒 **本地化配置** - 所有脚本打包在镜像内，无运行时远程下载

## 快速开始

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
      - LISTEN_PORT=6888
      - UPDATE_TRACKERS=true
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    restart: unless-stopped
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `RPC_SECRET` | (空) | RPC 访问密钥 |
| `RPC_PORT` | 6800 | RPC 监听端口 |
| `LISTEN_PORT` | 6888 | BT 监听端口 |
| `DISK_CACHE` | (空) | 磁盘缓存大小，如 `64M` |
| `UPDATE_TRACKERS` | true | 是否自动更新 Tracker |
| `CUSTOM_TRACKER_URL` | (空) | 自定义 Tracker 源 URL（追加到默认源） |
| `IPV6_MODE` | (空) | IPv6 模式，`true` 或 `false` |
| `PUID` / `PGID` | (空) | 运行用户/组 ID |
| `UMASK_SET` | 022 | 文件权限掩码 |

## 目录结构

| 路径 | 说明 |
|------|------|
| `/config` | 配置文件目录（持久化） |
| `/downloads` | 下载目录（持久化） |
| `/config/aria2.conf` | Aria2 主配置文件 |
| `/config/aria2.session` | 任务会话文件 |

## 构建

项目使用 GitHub Actions 自动构建。手动构建步骤：

```bash
# 1. 构建 s6-alpine 基础镜像
docker build -f Dockerfile-s6-alpine -t s6-alpine .

# 2. 构建 aria2（编译约需 20-40 分钟）
docker build -f Dockerfile-aria2-builder -t aria2-builder .
docker create --name tmp aria2-builder
docker cp tmp:/output/usr/bin/aria2c ./aria2-bin/linux/amd64/aria2c
docker rm tmp

# 3. 构建主镜像
docker build --build-arg S6_ALPINE_IMAGE=s6-alpine -t s6-aria2 .
```

## 致谢

- [aria2/aria2](https://github.com/aria2/aria2)
- [just-containers/s6-overlay](https://github.com/just-containers/s6-overlay)
- [P3TERX/Aria2-Pro-Docker](https://github.com/P3TERX/Aria2-Pro-Docker)
- [mayswind/AriaNg](https://github.com/mayswind/AriaNg)
- [emikulic/darkhttpd](https://github.com/emikulic/darkhttpd)
- [ngosang/trackerslist](https://github.com/ngosang/trackerslist)
- [XIU2/TrackersListCollection](https://github.com/XIU2/TrackersListCollection)

## License

MIT License
