# Cockpit Tools in Docker (full desktop GUI)

This runs the **official Cockpit Tools v1.4.2 Linux x86_64 desktop release** inside Ubuntu 24.04. The desktop is rendered by Xvfb/Openbox and streamed to a browser using VNC + noVNC. It is not a web rewrite of Cockpit Tools.

## Requirements

- Docker Desktop with the Linux container engine (Windows 11 / WSL2 backend is supported)
- An amd64 (Intel/AMD x64) host
- At least 4 CPU cores and 8 GB RAM recommended
- A browser on the same machine

## Start

From the repository root:

```powershell
docker compose up --build -d
```

Open:

```text
http://localhost:6080/vnc.html?autoconnect=true
```

The image downloads and installs the official Debian package from the upstream v1.4.2 GitHub Release during the Docker build. To change versions, override `COCKPIT_TOOLS_VERSION` and the matching `COCKPIT_TOOLS_DEB_URL` build arguments in the Dockerfile/Compose build configuration.

Stop:

```powershell
docker compose down
```

The named volume `cockpit-home` persists the container user's home directory, including Cockpit Tools data and supported Linux CLI configuration. To remove stored data as well, use `docker compose down -v` (this permanently deletes the volume).

## Security

- noVNC is published only on host loopback (`127.0.0.1:6080`).
- VNC listens only on container loopback; do not publish port 5900.
- Do not change the port binding to `0.0.0.0` on an untrusted network.
- Treat the persistent volume as sensitive: it may contain OAuth tokens and account configuration. Do not share or upload it.

## Functional limits

This is the full **Linux desktop GUI** running in a container, not the Windows-native build:

- It uses Linux WebKitGTK/GTK and Linux code paths.
- Local files, keyrings, processes, and CLI tools are inside the container. It cannot directly read Windows Credential Manager or launch Windows desktop applications.
- Features depending on native Windows/macOS apps, host OS process control, or Windows system integration may be unavailable or behave differently.
- The container's home volume persists across restarts. Back it up before removing the volume.
