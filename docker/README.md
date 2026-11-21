# Cockpit Tools in Docker (full desktop GUI)

This runs the **Linux desktop build** of Cockpit Tools inside a container. The desktop is rendered by Xvfb/Openbox and streamed to a browser using VNC + noVNC. It is not a web rewrite of Cockpit Tools.

## Requirements

- Docker Desktop with the Linux container engine (Windows 11 / WSL2 backend is supported)
- At least 4 CPU cores and 8 GB RAM recommended for the first image build
- A browser on the same machine

## Start

From the repository root:

```powershell
docker compose -f docker-compose.yml up --build -d
```

Open:

```text
http://localhost:6080/vnc.html?autoconnect=true
```

Stop:

```powershell
docker compose -f docker-compose.yml down
```

The named volume `cockpit-home` persists the container user's home directory, including Cockpit Tools data, Linux keyring data, and supported CLI configuration directories. To remove the stored data as well, use `docker compose -f docker-compose.yml down -v` (this permanently deletes the volume).

## Security

- The Compose file publishes noVNC only on host loopback (`127.0.0.1:6080`).
- VNC itself listens only on container loopback and has no password; do not publish port 5900.
- Do not change the port binding to `0.0.0.0` on an untrusted network. For remote access, put noVNC behind an authenticated HTTPS reverse proxy or access it through a VPN.
- Treat the persistent volume as sensitive: it may contain OAuth tokens, account metadata, and application configuration. Do not share or upload it.

## Important functional limits

This container provides the full Cockpit Tools Linux GUI, but it is **not the same as running the app natively on Windows**:

- Tauri's Linux WebKitGTK/GTK runtime is used. The app's Linux code paths are active.
- Local account files, keyrings, processes, and CLI tools are those inside the container. The app cannot directly read Windows host credential stores or launch Windows desktop applications.
- Features that depend on native Windows/macOS apps, Windows Credential Manager, system tray integration, host filesystem paths, or host OS process control may be unavailable or behave differently.
- If you need the app to manage tools installed on Windows itself, use the native Windows build instead; a container is an isolated Linux environment.

For Linux Tauri builds, Cockpit Tools depends on WebKitGTK 4.1 and related system libraries. This image uses Ubuntu 24.04 and installs those dependencies as described in the official Tauri prerequisites: https://v2.tauri.app/start/prerequisites/
