# syntax=docker/dockerfile:1
# Run the official Cockpit Tools Linux desktop release in an isolated
# virtual X11 desktop, streamed to the browser through noVNC.
FROM ubuntu:24.04

ARG COCKPIT_TOOLS_VERSION=1.4.2
ARG COCKPIT_TOOLS_DEB_URL=https://github.com/jlcodes99/cockpit-tools/releases/download/v${COCKPIT_TOOLS_VERSION}/Cockpit.Tools_${COCKPIT_TOOLS_VERSION}_amd64.deb

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    GDK_BACKEND=x11 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    WEBKIT_DISABLE_COMPOSITING_MODE=1 \
    HOME=/home/cockpit \
    COCKPIT_TOOLS_DATA_DIR=/home/cockpit/.cockpit_tools

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    libwebkit2gtk-4.1-0 libjavascriptcoregtk-4.1-0 libgtk-3-0t64 \
    libayatana-appindicator3-1 libayatana-ido3-0 libsecret-1-0 libsecret-tools \
    libxdo3 librsvg2-2 libssl3t64 libnotify4 \
    dbus-x11 gnome-keyring \
    xvfb x11vnc openbox novnc websockify x11-utils xdotool \
    fonts-liberation fonts-noto-cjk \
    && curl -fL --retry 3 "${COCKPIT_TOOLS_DEB_URL}" -o /tmp/cockpit-tools.deb \
    && apt-get install -y --no-install-recommends /tmp/cockpit-tools.deb \
    && rm -f /tmp/cockpit-tools.deb \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 10001 --shell /bin/bash cockpit \
    && mkdir -p /home/cockpit/.cockpit_tools \
    && chown -R cockpit:cockpit /home/cockpit \
    && command -v cockpit-tools

COPY docker/entrypoint.sh /usr/local/bin/cockpit-entrypoint
RUN chmod 0755 /usr/local/bin/cockpit-entrypoint

USER cockpit
WORKDIR /home/cockpit
EXPOSE 6080
VOLUME ["/home/cockpit"]
ENTRYPOINT ["/usr/local/bin/cockpit-entrypoint"]
