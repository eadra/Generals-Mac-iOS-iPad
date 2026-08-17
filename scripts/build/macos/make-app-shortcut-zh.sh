#!/usr/bin/env bash
# GeneralsX @feature 16/08/2026 Build a Finder/Applications launcher .app for Zero Hour.
#
# Creates a tiny .app bundle whose executable is a shell script that runs the
# deployed ~/GeneralsX/GeneralsZH/run.sh with the preferred flags. The game
# itself is not copied into the bundle; deploy-macos-zh.sh still owns that.
#
# Usage:
#   ./scripts/build/macos/make-app-shortcut-zh.sh [INSTALL_DIR]
#
# Environment:
#   APP_NAME    Bundle name without .app   (default: Generals Zero Hour)
#   GAME_DIR    Deployed runtime directory (default: $HOME/GeneralsX/GeneralsZH)
#   GAME_FLAGS  Flags passed to run.sh     (default: -win -mod ControlBarPro_BarOnly.big -fps 60)
#   ICON_PNG    Square source image        (default: assets/generalsx-zh_icon.png)

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

INSTALL_DIR="${1:-/Applications}"
APP_NAME="${APP_NAME:-Generals Zero Hour}"
GAME_DIR="${GAME_DIR:-${HOME}/GeneralsX/GeneralsZH}"
GAME_FLAGS="${GAME_FLAGS:--win -mod ControlBarPro_BarOnly.big -fps 60}"
ICON_PNG="${ICON_PNG:-${PROJECT_ROOT}/assets/generalsx-zh_icon.png}"

APP="${INSTALL_DIR}/${APP_NAME}.app"
CONTENTS="${APP}/Contents"

if [[ ! -f "${ICON_PNG}" ]]; then
    echo "ERROR: icon source not found: ${ICON_PNG}" >&2
    exit 1
fi
if [[ ! -d "${INSTALL_DIR}" ]]; then
    echo "ERROR: install directory not found: ${INSTALL_DIR}" >&2
    exit 1
fi
if [[ ! -x "${GAME_DIR}/run.sh" ]]; then
    echo "WARNING: ${GAME_DIR}/run.sh not found — run deploy-macos-zh.sh before launching." >&2
fi

rm -rf "${APP}"
mkdir -p "${CONTENTS}/MacOS" "${CONTENTS}/Resources"

# Icon: sips/iconutil want a .iconset of the standard sizes.
ICONSET="$(mktemp -d)/GeneralsZH.iconset"
mkdir -p "${ICONSET}"
for size in 16 32 128 256 512; do
    sips -z "${size}" "${size}" "${ICON_PNG}" \
        --out "${ICONSET}/icon_${size}x${size}.png" >/dev/null
    sips -z "$((size * 2))" "$((size * 2))" "${ICON_PNG}" \
        --out "${ICONSET}/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "${ICONSET}" -o "${CONTENTS}/Resources/GeneralsZH.icns"
rm -rf "$(dirname "${ICONSET}")"

cat > "${CONTENTS}/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>     <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>      <string>com.generalsx.zerohour.launcher</string>
    <key>CFBundleExecutable</key>      <string>launch</string>
    <key>CFBundleIconFile</key>        <string>GeneralsZH</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>NSHighResolutionCapable</key> <true/>
</dict>
</plist>
PLIST

# The bundle is a thin wrapper: run.sh owns the dylib paths, MoltenVK ICD and cwd.
cat > "${CONTENTS}/MacOS/launch" << LAUNCHER
#!/bin/bash
GAME_DIR="${GAME_DIR}"

if [[ ! -x "\${GAME_DIR}/run.sh" ]]; then
    osascript -e 'display alert "Zero Hour not deployed" message "Expected ${GAME_DIR}/run.sh. Run scripts/build/macos/deploy-macos-zh.sh first." as critical'
    exit 1
fi

exec "\${GAME_DIR}/run.sh" ${GAME_FLAGS}
LAUNCHER
chmod +x "${CONTENTS}/MacOS/launch"

# Nudge Finder to pick up the new icon instead of a cached generic one.
touch "${APP}"

echo "Created ${APP}"
echo "  launches: ${GAME_DIR}/run.sh ${GAME_FLAGS}"
