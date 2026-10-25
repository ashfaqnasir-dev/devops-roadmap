#!/bin/bash
set -euo pipefail

APP_NAME="myapp"
BUILD_DIR="build"
LOG_FILE="build.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log "Error: $1 install nahi hai"
        exit 1
    fi
    log "$1 mojood hai"
}

log "Build shuru: $APP_NAME"

check_command "bash"
check_command "grep"
check_command "awk"

log "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

STEPS=("Compiling" "Testing" "Packaging")

for step in "${STEPS[@]}"; do
    log "  -> $step..."
    sleep 1
    log "  $step complete"
done

log "Creating artifact..."
echo "Build: $APP_NAME" > "$BUILD_DIR/app.txt"
echo "Version: 1.0.0" >> "$BUILD_DIR/app.txt"
echo "Date: $(date)" >> "$BUILD_DIR/app.txt"

if [ -f "$BUILD_DIR/app.txt" ]; then
    log "Artifact created: $BUILD_DIR/app.txt"
else
    log "Artifact not created"
    exit 1
fi

log ""
log "=========================================="
log "Build successful!"
log "Artifact: $BUILD_DIR/"
log "Log: $LOG_FILE"
log "=========================================="

exit 0
