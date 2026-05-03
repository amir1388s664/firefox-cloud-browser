#!/bin/bash

# ============================================================
#   🦊 Firefox Cloud Browser
#   تولید شده توسط امیرمهدی محمدزاده
# ============================================================

set -e

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; }
info()   { echo -e "${CYAN}[→]${NC} $1"; }

echo -e "${PURPLE}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     🦊 Firefox Cloud Browser              ║"
echo "  ║   تولید شده توسط امیرمهدی محمدزاده       ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# متغیرها
# ============================================================
DISPLAY_NUM=":99"
SCREEN_RES="1280x720x24"
VNC_PORT=5900
NOVNC_PORT=6080
LOG_DIR="/tmp/browser-logs"
NOVNC_PATH="/opt/novnc"
FIREFOX_PROFILE="/tmp/ff-profile"

mkdir -p "$LOG_DIR" "$FIREFOX_PROFILE"

# ============================================================
# پاکسازی پردازش‌های قبلی
# ============================================================
info "پاکسازی پردازش‌های قبلی..."
pkill -9 -f Xvfb       2>/dev/null || true
pkill -9 -f x11vnc     2>/dev/null || true
pkill -9 -f fluxbox    2>/dev/null || true
pkill -9 -f firefox    2>/dev/null || true
pkill -9 -f websockify 2>/dev/null || true
rm -f /tmp/.X99-lock /tmp/.X*-lock 2>/dev/null || true
sleep 2

# ============================================================
# مرحله ۱: Xvfb
# ============================================================
info "راه‌اندازی دیسپلی مجازی..."
Xvfb $DISPLAY_NUM \
    -screen 0 $SCREEN_RES \
    -ac \
    +extension GLX \
    +render \
    -noreset \
    > "$LOG_DIR/xvfb.log" 2>&1 &
XVFB_PID=$!
sleep 3

if ! kill -0 $XVFB_PID 2>/dev/null; then
    error "Xvfb شروع نشد!"
    cat "$LOG_DIR/xvfb.log"
    exit 1
fi
log "Xvfb آماده است (PID: $XVFB_PID)"

export DISPLAY=$DISPLAY_NUM

# ============================================================
# مرحله ۲: Fluxbox
# ============================================================
info "راه‌اندازی محیط گرافیکی..."

# تنظیمات fluxbox
cat > /root/.fluxbox/init << 'FBEOF'
session.screen0.toolbar.visible: false
session.screen0.rootCommand: xsetroot -solid "#0d1117"
session.screen0.workspaces: 1
FBEOF

cat > /root/.fluxbox/apps << 'FBEOF'
[app] (name=firefox)
  [Maximized] {yes}
[end]
FBEOF

fluxbox > "$LOG_DIR/fluxbox.log" 2>&1 &
FLUXBOX_PID=$!
sleep 2
log "Fluxbox آماده است (PID: $FLUXBOX_PID)"

# تنظیم رنگ پس‌زمینه
xsetroot -solid "#0d1117" 2>/dev/null || true

# ============================================================
# مرحله ۳: x11vnc
# ============================================================
info "راه‌اندازی VNC..."
x11vnc \
    -display $DISPLAY_NUM \
    -nopw \
    -listen localhost \
    -port $VNC_PORT \
    -shared \
    -forever \
    -noxdamage \
    -noxrecord \
    -noxfixes \
    -quiet \
    -bg \
    > "$LOG_DIR/x11vnc.log" 2>&1

sleep 3
log "x11vnc روی پورت $VNC_PORT آماده است"

# ============================================================
# مرحله ۴: تنظیمات Firefox
# ============================================================
info "تنظیم پروفایل Firefox..."

# user.js برای رفع محدودیت‌ها
cat > "$FIREFOX_PROFILE/user.js" << 'FFEOF'
// ========================================
// رفع محدودیت‌های امنیتی برای محیط مجازی
// ========================================

// sandbox
user_pref("security.sandbox.content.level", 0);
user_pref("security.sandbox.gpu.level", 0);
user_pref("security.sandbox.media.new", false);

// غیرفعال کردن بروزرسانی
user_pref("app.update.auto", false);
user_pref("app.update.enabled", false);
user_pref("app.update.silent", false);

// صفحه شروع
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.startup.page", 0);

// غیرفعال کردن telemetry
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);

// غیرفعال کردن صفحه خوش‌آمدگویی
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.startup.firstrunSkipsHomepage", true);
user_pref("trailhead.firstrun.didSeeAboutWelcome", true);

// رفع مشکل GPU در محیط مجازی
user_pref("layers.acceleration.disabled", true);
user_pref("gfx.webrender.all", false);
user_pref("gfx.webrender.enabled", false);
user_pref("media.hardware-video-decoding.enabled", false);

// رفع مشکل DRM
user_pref("media.eme.enabled", true);
user_pref("media.gmp-widevinecdm.enabled", true);

// غیرفعال کردن heuristic‌های محدودکننده
user_pref("privacy.trackingprotection.enabled", false);
user_pref("network.cookie.cookieBehavior", 0);

// رفع مشکل iframe
user_pref("security.mixed_content.block_display_content", false);
user_pref("security.mixed_content.block_active_content", false);

// بهبود عملکرد
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);

// غیرفعال کردن پاپ‌آپ‌های اضافه
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.warnOnQuit", false);
FFEOF

log "پروفایل Firefox آماده است"

# ============================================================
# مرحله ۵: ساخت صفحه noVNC سفارشی
# ============================================================
info "شخصی‌سازی رابط noVNC..."

cat > "$NOVNC_PATH/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🦊 Firefox Cloud — امیرمهدی محمدزاده</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background: #0d1117;
            font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
            color: #c9d1d9;
            display: flex;
            flex-direction: column;
            height: 100vh;
            overflow: hidden;
        }

        /* ── نوار بالا ── */
        .topbar {
            background: linear-gradient(135deg, #161b22, #21262d);
            border-bottom: 2px solid #ff6b35;
            padding: 8px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-shrink: 0;
            z-index: 100;
            box-shadow: 0 2px 15px rgba(255,107,53,0.3);
        }

        .topbar-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo {
            font-size: 24px;
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-3px); }
        }

        .title-group {
            display: flex;
            flex-direction: column;
        }

        .main-title {
            font-size: 15px;
            font-weight: 700;
            color: #ff6b35;
            letter-spacing: 0.5px;
        }

        .sub-title {
            font-size: 11px;
            color: #8b949e;
            direction: rtl;
        }

        .topbar-center {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* دکمه‌های میانبر */
        .shortcut-btn {
            background: #21262d;
            border: 1px solid #30363d;
            color: #c9d1d9;
            padding: 5px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .shortcut-btn:hover {
            background: #ff6b35;
            border-color: #ff6b35;
            color: white;
            transform: translateY(-1px);
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #3fb950;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; box-shadow: 0 0 0 0 rgba(63,185,80,0.4); }
            50% { opacity: 0.8; box-shadow: 0 0 0 6px rgba(63,185,80,0); }
        }

        .status-text {
            font-size: 12px;
            color: #3fb950;
            font-weight: 600;
        }

        .credit {
            font-size: 11px;
            color: #6e7681;
            border-right: 1px solid #30363d;
            padding-right: 10px;
            direction: rtl;
        }

        /* ── محفظه اصلی ── */
        .main-container {
            flex: 1;
            position: relative;
            overflow: hidden;
        }

        /* لودینگ */
        .loading-screen {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: #0d1117;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 50;
            transition: opacity 0.5s ease;
        }

        .loading-screen.hidden {
            opacity: 0;
            pointer-events: none;
        }

        .loading-logo { font-size: 64px; margin-bottom: 20px; }

        .loading-bar-container {
            width: 300px;
            height: 4px;
            background: #21262d;
            border-radius: 2px;
            margin: 20px 0;
            overflow: hidden;
        }

        .loading-bar {
            height: 100%;
            background: linear-gradient(90deg, #ff6b35, #ff9500);
            border-radius: 2px;
            animation: load 3s ease-out forwards;
        }

        @keyframes load {
            0% { width: 0%; }
            30% { width: 40%; }
            60% { width: 70%; }
            100% { width: 100%; }
        }

        .loading-text {
            color: #8b949e;
            font-size: 14px;
            margin-top: 10px;
            direction: rtl;
        }

        /* iframe مرورگر */
        #vnc-frame {
            width: 100%;
            height: 100%;
            border: none;
            display: block;
        }

        /* نوار پایین */
        .bottombar {
            background: #161b22;
            border-top: 1px solid #21262d;
            padding: 4px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-shrink: 0;
            font-size: 11px;
            color: #6e7681;
        }

        .bottombar-left { direction: rtl; }
        .bottombar-right { display: flex; gap: 15px; }
        .bottombar-right span { cursor: default; }
    </style>
</head>
<body>

    <!-- نوار بالا -->
    <div class="topbar">
        <div class="topbar-left">
            <span class="logo">🦊</span>
            <div class="title-group">
                <span class="main-title">Firefox Cloud Browser</span>
                <span class="sub-title">تولید شده توسط امیرمهدی محمدزاده</span>
            </div>
        </div>

        <div class="topbar-center">
            <a class="shortcut-btn" onclick="goTo('https://www.youtube.com')">▶ یوتیوب</a>
            <a class="shortcut-btn" onclick="goTo('https://www.google.com')">🔍 گوگل</a>
            <a class="shortcut-btn" onclick="goTo('https://github.com')">🐙 گیتهاب</a>
            <a class="shortcut-btn" onclick="goTo('https://www.netflix.com')">🎬 نتفلیکس</a>
            <a class="shortcut-btn" onclick="reloadVNC()">🔄 بارگذاری مجدد</a>
        </div>

        <div class="topbar-right">
            <span class="credit">تولید شده توسط امیرمهدی محمدزاده</span>
            <div class="status-dot"></div>
            <span class="status-text">آنلاین</span>
        </div>
    </div>

    <!-- محفظه اصلی -->
    <div class="main-container">

        <!-- صفحه لودینگ -->
        <div class="loading-screen" id="loading">
            <div class="loading-logo">🦊</div>
            <h2 style="color:#ff6b35; margin-bottom:8px;">Firefox Cloud Browser</h2>
            <p style="color:#8b949e; font-size:13px; direction:rtl;">
                تولید شده توسط امیرمهدی محمدزاده
            </p>
            <div class="loading-bar-container">
                <div class="loading-bar"></div>
            </div>
            <p class="loading-text">در حال اتصال به مرورگر...</p>
        </div>

        <!-- noVNC viewer -->
        <iframe
            id="vnc-frame"
            src="/vnc.html?autoconnect=true&reconnect=true&reconnect_delay=2000&resize=scale&quality=6&compression=2&show_dot=false&path=websockify"
            allow="fullscreen"
            onload="frameLoaded()"
        ></iframe>

    </div>

    <!-- نوار پایین -->
    <div class="bottombar">
        <div class="bottombar-left">
            🦊 Firefox Cloud Browser — تولید شده توسط امیرمهدی محمدزاده
        </div>
        <div class="bottombar-right">
            <span>📡 پورت: 6080</span>
            <span>🖥️ 1280×720</span>
            <span>🔒 VNC Secure</span>
        </div>
    </div>

    <script>
        // مخفی کردن صفحه لودینگ بعد از اتصال
        function frameLoaded() {
            setTimeout(() => {
                const loading = document.getElementById('loading');
                loading.classList.add('hidden');
                setTimeout(() => loading.remove(), 500);
            }, 3000);
        }

        // اگر iframe لود نشد به صورت دستی مخفی کن
        setTimeout(() => {
            const loading = document.getElementById('loading');
            if (loading) {
                loading.classList.add('hidden');
                setTimeout(() => loading.remove(), 500);
            }
        }, 6000);

        // رفتن به یک سایت از طریق JavaScript
        // (از طریق URL پارامتر به noVNC منتقل می‌شود)
        function goTo(url) {
            // این دکمه‌ها برای راحتی کاربر هستند
            // کاربر باید در مرورگر Firefox آدرس را تایپ کند
            const msg = `آدرس زیر را در Firefox کپی کنید:\n\n${url}`;
            if (confirm(`آیا می‌خواهید به ${url} بروید؟\n\nروی OK کلیک کنید تا آدرس کپی شود.`)) {
                navigator.clipboard.writeText(url).then(() => {
                    alert('✅ آدرس کپی شد!\nآن را در نوار آدرس Firefox پیست کنید (Ctrl+L سپس Ctrl+V)');
                }).catch(() => {
                    prompt('آدرس را کپی کنید:', url);
                });
            }
        }

        function reloadVNC() {
            const frame = document.getElementById('vnc-frame');
            frame.src = frame.src;
        }
    </script>

</body>
</html>
HTMLEOF

log "رابط کاربری noVNC شخصی‌سازی شد"

# ============================================================
# مرحله ۶: راه‌اندازی Firefox
# ============================================================
info "راه‌اندازی Firefox..."

firefox \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --profile "$FIREFOX_PROFILE" \
    --new-instance \
    "https://www.google.com" \
    > "$LOG_DIR/firefox.log" 2>&1 &

FIREFOX_PID=$!
sleep 4
log "Firefox آماده است (PID: $FIREFOX_PID)"

# ============================================================
# مرحله ۷: websockify
# ============================================================
info "راه‌اندازی websockify در پورت $NOVNC_PORT..."

# تلاش با websockify سیستم
if command -v websockify &>/dev/null; then
    websockify \
        --web "$NOVNC_PATH" \
        --heartbeat 30 \
        $NOVNC_PORT \
        localhost:$VNC_PORT \
        > "$LOG_DIR/websockify.log" 2>&1 &
elif python3 -c "import websockify" 2>/dev/null; then
    python3 -m websockify \
        --web "$NOVNC_PATH" \
        --heartbeat 30 \
        $NOVNC_PORT \
        localhost:$VNC_PORT \
        > "$LOG_DIR/websockify.log" 2>&1 &
else
    error "websockify پیدا نشد!"
    exit 1
fi

WEBSOCKIFY_PID=$!
sleep 3

if ! kill -0 $WEBSOCKIFY_PID 2>/dev/null; then
    error "websockify شروع نشد!"
    cat "$LOG_DIR/websockify.log"
    exit 1
fi

log "websockify روی پورت $NOVNC_PORT آماده است (PID: $WEBSOCKIFY_PID)"

# ============================================================
# نمایش اطلاعات نهایی
# ============================================================
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${GREEN}✅ همه سرویس‌ها با موفقیت راه‌اندازی شدند!${NC}     ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  🌐 آدرس: ${YELLOW}http://localhost:$NOVNC_PORT${NC}               ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  🦊 Firefox در حال اجرا                          ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  👤 تولید شده توسط امیرمهدی محمدزاده             ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  PIDs: Xvfb=$XVFB_PID Fluxbox=$FLUXBOX_PID Firefox=$FIREFOX_PID WS=$WEBSOCKIFY_PID ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================
# نظارت و نگه‌داشتن سرویس‌ها
# ============================================================
while true; do
    sleep 20

    # بررسی و راه‌اندازی مجدد x11vnc
    if ! pgrep -x x11vnc > /dev/null 2>&1; then
        warn "x11vnc متوقف شد — راه‌اندازی مجدد..."
        x11vnc -display $DISPLAY_NUM -nopw -listen localhost \
            -port $VNC_PORT -shared -forever -noxdamage -quiet -bg \
            > "$LOG_DIR/x11vnc.log" 2>&1
        sleep 2
    fi

    # بررسی و راه‌اندازی مجدد websockify
    if ! kill -0 $WEBSOCKIFY_PID 2>/dev/null; then
        warn "websockify متوقف شد — راه‌اندازی مجدد..."
        if command -v websockify &>/dev/null; then
            websockify --web "$NOVNC_PATH" --heartbeat 30 \
                $NOVNC_PORT localhost:$VNC_PORT \
                > "$LOG_DIR/websockify.log" 2>&1 &
        else
            python3 -m websockify --web "$NOVNC_PATH" --heartbeat 30 \
                $NOVNC_PORT localhost:$VNC_PORT \
                > "$LOG_DIR/websockify.log" 2>&1 &
        fi
        WEBSOCKIFY_PID=$!
        sleep 2
    fi

    # بررسی و راه‌اندازی مجدد firefox
    if ! kill -0 $FIREFOX_PID 2>/dev/null; then
        warn "Firefox بسته شد — راه‌اندازی مجدد..."
        firefox --no-sandbox --disable-dev-shm-usage --disable-gpu \
            --profile "$FIREFOX_PROFILE" --new-instance \
            "https://www.google.com" \
            > "$LOG_DIR/firefox.log" 2>&1 &
        FIREFOX_PID=$!
        sleep 3
    fi

done
