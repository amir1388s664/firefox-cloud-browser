FROM ubuntu:22.04

# جلوگیری از پرسش‌های تعاملی
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran
ENV DISPLAY=:99
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24
ENV VNC_PORT=5900
ENV NOVNC_PORT=6080
ENV HOME=/root

# به‌روزرسانی و نصب همه پکیج‌ها
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    x11-utils \
    x11-xserver-utils \
    dbus-x11 \
    firefox \
    python3 \
    python3-pip \
    net-tools \
    websockify \
    novnc \
    fonts-liberation \
    fonts-noto \
    fonts-noto-color-emoji \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# نصب websockify از pip در صورت نیاز
RUN pip3 install websockify 2>/dev/null || true

# دانلود noVNC مستقیم از GitHub برای اطمینان
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
    && ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# ساخت دایرکتوری workspace
RUN mkdir -p /workspace /root/.fluxbox /root/.mozilla

# کپی اسکریپت
COPY start-browser.sh /workspace/start-browser.sh
RUN chmod +x /workspace/start-browser.sh

WORKDIR /workspace
EXPOSE 6080
