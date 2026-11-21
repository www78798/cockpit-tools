# syntax=docker/dockerfile:1
# Build Cockpit Tools as a native Linux/Tauri application, then run it in a
# lightweight virtual X11 desktop exposed through noVNC.
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=/usr/local/cargo/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl file pkg-config libssl-dev libxdo-dev \
    libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev \
    libgtk-3-dev libsecret-1-dev ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal

WORKDIR /src
COPY . .

RUN npm ci --no-audit --no-fund \
    && npm run tauri -- build --no-bundle \
    && install -D -m 0755 src-tauri/target/release/cockpit-tools /out/cockpit-tools

FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    GDK_BACKEND=x11 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    WEBKIT_DISABLE_COMPOSITING_MODE=1 \
    HOME=/home/cockpit \
    COCKPIT_TOOLS_DATA_DIR=/home/cockpit/.cockpit_tools

RUN apt-get update && apt-get install -y --no-install-recommends \
    libwebkit2gtk-4.1-0 libjavascriptcoregtk-4.1-0 libgtk-3-0t64 \
    libayatana-appindicator3-1 libayatana-ido3-0 libsecret-1-0 \
    libxdo3 librsvg2-2 libssl3t64 libnotify4 dbus-x11 gnome-keyring \
    xvfb x11vnc openbox novnc websockify x11-utils xdotool \
    fonts-liberation fonts-noto-cjk ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 10001 --shell /bin/bash cockpit \
    && mkdir -p /home/cockpit/.cockpit_tools /opt/cockpit \
    && chown -R cockpit:cockpit /home/cockpit /opt/cockpit

COPY --from=builder /out/cockpit-tools /usr/local/bin/cockpit-tools
COPY docker/entrypoint.sh /usr/local/bin/cockpit-entrypoint
RUN chmod 0755 /usr/local/bin/cockpit-entrypoint

USER cockpit
WORKDIR /home/cockpit
EXPOSE 6080
VOLUME ["/home/cockpit"]
ENTRYPOINT ["/usr/local/bin/cockpit-entrypoint"]
