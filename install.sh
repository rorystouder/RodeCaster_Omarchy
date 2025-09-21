#!/bin/bash
# Purpose: Install Rodecaster Pro integration for Omarchy/Arch Linux
# Dependencies: pacman, systemd
# Usage: sudo ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/scripts/utils.sh"

install_dependencies() {
    log_info "Checking for required packages..."

    local packages=(
        "alsa-utils"
        "usbutils"
    )

    if command -v pacman &>/dev/null; then
        for pkg in "${packages[@]}"; do
            if ! pacman -Q "$pkg" &>/dev/null; then
                log_info "Installing $pkg..."
                pacman -S --noconfirm "$pkg"
            fi
        done
    else
        log_error "This installer requires pacman (Arch/Omarchy)"
        exit 1
    fi
}

install_scripts() {
    log_info "Installing scripts..."

    install -m 755 "${SCRIPT_DIR}/scripts/detect.sh" /usr/local/bin/rodecaster-detect
    install -m 755 "${SCRIPT_DIR}/scripts/configure.sh" /usr/local/bin/rodecaster-configure

    log_info "Scripts installed to /usr/local/bin/"
}

install_configs() {
    log_info "Installing configuration files..."

    install -m 644 "${SCRIPT_DIR}/config/udev/99-rodecaster.rules" /etc/udev/rules.d/

    if [ -d /usr/share/alsa/cards ]; then
        install -m 644 "${SCRIPT_DIR}/config/alsa/rodecaster.conf" /usr/share/alsa/cards/
    fi

    if [ -d /etc/pipewire/pipewire.conf.d ]; then
        install -m 644 "${SCRIPT_DIR}/config/pipewire/rodecaster.conf" /etc/pipewire/pipewire.conf.d/
    elif [ -d /usr/share/pipewire/pipewire.conf.d ]; then
        install -m 644 "${SCRIPT_DIR}/config/pipewire/rodecaster.conf" /usr/share/pipewire/pipewire.conf.d/
    fi

    log_info "Configuration files installed"
}

reload_services() {
    log_info "Reloading services..."

    udevadm control --reload-rules
    udevadm trigger --subsystem-match=usb

    if systemctl --user is-active pipewire &>/dev/null; then
        systemctl --user restart pipewire pipewire-pulse
    fi

    log_info "Services reloaded"
}

main() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root (use sudo)"
        exit 1
    fi

    log_info "=== Rodecaster Pro Omarchy Integration Installer ==="

    install_dependencies
    install_scripts
    install_configs
    reload_services

    log_info "=== Installation Complete ==="
    log_info "Connect your Rodecaster Pro and run: rodecaster-detect"
    log_info "To configure: rodecaster-configure"
}

main "$@"