#!/usr/bin/env bash
# =============================================================================
# refresh_rate — Screenshot Capture
#
# Runs flutter drive against the example app, capturing screenshots of all
# key UI states. Screenshots are saved to the package root screenshots/ dir
# and become the README / pub.dev assets.
#
# Usage:
#   ./scripts/take_screenshots.sh
#   ./scripts/take_screenshots.sh -d <device-id>
#
# Examples:
#   ./scripts/take_screenshots.sh -d iPhone
#   ./scripts/take_screenshots.sh -d emulator-5554
#   ./scripts/take_screenshots.sh -d macos
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$PKG_ROOT/example"
SCREENSHOTS_DIR="$PKG_ROOT/screenshots"

# ── Parse CLI flags ───────────────────────────────────────────────────────────
CLI_DEVICE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--device) CLI_DEVICE="$2"; shift 2 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done

# ── Colours ───────────────────────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'
C='\033[0;36m'; B='\033[1m'; D='\033[2m'; N='\033[0m'

sep2() { echo -e "${C}${B}════════════════════════════════════════════════${N}"; }

sep2
echo -e "${C}${B}  refresh_rate · Screenshot Capture${N}"
sep2
echo ""

# ── Device selection ──────────────────────────────────────────────────────────
DEVICE_ID=""

if [[ -n "$CLI_DEVICE" ]]; then
  DEVICE_ID="$CLI_DEVICE"
  echo -e "  ${G}Using device:${N} ${B}$DEVICE_ID${N}"
else
  echo -e "${B}  Detecting available devices…${N}"
  echo ""

  DEV_IDS=(); DEV_NAMES=()
  while IFS= read -r line; do
    did=$(echo "$line"  | awk -F'•' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
    dname=$(echo "$line" | awk -F'•' '{gsub(/^[ \t]+|[ \t]+$/,"",$1); print $1}')
    [[ -n "$did" ]] || continue
    DEV_IDS+=("$did")
    DEV_NAMES+=("$dname")
  done < <(flutter devices 2>/dev/null | grep '•')

  if [[ ${#DEV_IDS[@]} -eq 0 ]]; then
    echo -e "  ${R}No devices found. Connect a device or start a simulator.${N}"
    exit 1
  fi

  echo -e "  ${B}Select a device:${N}"
  echo ""
  for i in "${!DEV_IDS[@]}"; do
    printf "  ${C}${B}[%d]${N}  %s  ${D}(%s)${N}\n" "$((i+1))" "${DEV_NAMES[$i]}" "${DEV_IDS[$i]}"
  done
  echo ""
  printf "  Choice [1-%d]: " "${#DEV_IDS[@]}"
  read -r choice

  idx=$((choice - 1))
  DEVICE_ID="${DEV_IDS[$idx]}"
  echo -e "\n  ${G}Running on:${N} ${B}${DEV_NAMES[$idx]}${N} ${D}($DEVICE_ID)${N}"
fi

echo ""

# ── Run flutter drive ─────────────────────────────────────────────────────────
mkdir -p "$SCREENSHOTS_DIR"

echo -e "  ${B}Capturing screenshots…${N}"
echo ""

cd "$EXAMPLE_DIR"
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  -d "$DEVICE_ID"

echo ""
sep2
echo -e "${C}${B}  Done!${N}"
sep2
echo ""
echo -e "  Screenshots saved to:  ${B}screenshots/${N}"
echo ""

shopt -s nullglob
pngs=("$SCREENSHOTS_DIR"/*.png)
if [[ ${#pngs[@]} -eq 0 ]]; then
  echo -e "  ${R}No .png files found — check that the driver saved files correctly.${N}"
else
  for f in "${pngs[@]}"; do
    echo -e "  ${G}✔${N}  $(basename "$f")"
  done
fi
echo ""
