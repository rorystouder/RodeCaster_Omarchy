#!/bin/bash
# Purpose: Utility functions for Rodecaster integration
# Dependencies: coreutils
# Usage: source utils.sh

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

check_dependencies() {
    local deps=("$@")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        return 1
    fi

    return 0
}

is_rodecaster_connected() {
    lsusb 2>/dev/null | grep -q "19f7:001[567]"
}

get_rodecaster_card_number() {
    if [ -f /proc/asound/cards ]; then
        grep -i "rodecaster\|rode" /proc/asound/cards | awk '{print $1}'
    fi
}

restart_audio_service() {
    if systemctl --user is-active pipewire &>/dev/null; then
        systemctl --user restart pipewire pipewire-pulse
        log_info "Restarted PipeWire"
    elif systemctl --user is-active pulseaudio &>/dev/null; then
        systemctl --user restart pulseaudio
        log_info "Restarted PulseAudio"
    fi
}

backup_config() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        cp "$config_file" "${config_file}.bak.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up: $config_file"
    fi
}