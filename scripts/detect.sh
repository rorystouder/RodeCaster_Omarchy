#!/bin/bash
# Purpose: Detect Rodecaster Pro/Pro II USB audio device
# Dependencies: usbutils, alsa-utils
# Usage: detect.sh

RODE_VENDOR_ID="19f7"
RODE_PRODUCT_IDS=("0015" "0016" "0017")

detect_usb() {
    if ! command -v lsusb &> /dev/null; then
        echo "Error: lsusb not found. Install usbutils package."
        return 1
    fi

    for pid in "${RODE_PRODUCT_IDS[@]}"; do
        if lsusb | grep -q "${RODE_VENDOR_ID}:${pid}"; then
            echo "Found: Rodecaster Pro (USB ID: ${RODE_VENDOR_ID}:${pid})"
            return 0
        fi
    done

    return 1
}

detect_alsa() {
    if [ ! -f /proc/asound/cards ]; then
        echo "Error: ALSA not available"
        return 1
    fi

    if grep -qi "rodecaster\|rode" /proc/asound/cards; then
        card_num=$(grep -i "rodecaster\|rode" /proc/asound/cards | awk '{print $1}')
        echo "Found: Rodecaster on ALSA card ${card_num}"

        if [ -d "/proc/asound/card${card_num}" ]; then
            cat "/proc/asound/card${card_num}/stream0" 2>/dev/null
        fi
        return 0
    fi

    return 1
}

main() {
    echo "=== Rodecaster Pro Detection ==="

    if detect_usb; then
        echo "✓ USB device detected"
    else
        echo "✗ USB device not found"
    fi

    if detect_alsa; then
        echo "✓ ALSA device detected"
    else
        echo "✗ ALSA device not found"
    fi
}

main "$@"