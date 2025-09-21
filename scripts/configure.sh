#!/bin/bash
# Purpose: Configure Rodecaster Pro audio settings using standard tools
# Dependencies: alsa-utils, pipewire/pulseaudio-utils
# Usage: configure.sh [--backend pipewire|pulseaudio]

BACKEND="${1:-pipewire}"
SAMPLE_RATE="48000"
BIT_DEPTH="24"
CARD_NAME=""

find_rodecaster_card() {
    if [ ! -f /proc/asound/cards ]; then
        return 1
    fi

    CARD_NAME=$(cat /proc/asound/cards | grep -i "rodecaster\|rode" | sed 's/.*\[\(.*\)\].*/\1/')
    if [ -z "$CARD_NAME" ]; then
        return 1
    fi

    echo "Found card: $CARD_NAME"
    return 0
}

configure_alsa() {
    if ! command -v amixer &> /dev/null; then
        echo "Error: amixer not found. Install alsa-utils."
        return 1
    fi

    echo "Configuring ALSA for $CARD_NAME..."

    amixer -c "$CARD_NAME" set PCM 100% unmute 2>/dev/null
    amixer -c "$CARD_NAME" set Master 100% unmute 2>/dev/null

    alsactl store "$CARD_NAME" 2>/dev/null

    echo "ALSA configuration complete"
}

configure_pipewire() {
    if ! command -v pw-cli &> /dev/null; then
        echo "Warning: pw-cli not found. Trying wpctl..."

        if command -v wpctl &> /dev/null; then
            wpctl status | grep -i rode
            return $?
        else
            echo "Error: PipeWire tools not found"
            return 1
        fi
    fi

    echo "Configuring PipeWire for Rodecaster..."

    pw-metadata -n settings 0 clock.rate "$SAMPLE_RATE"
    pw-metadata -n settings 0 clock.allowed-rates "[ $SAMPLE_RATE ]"

    echo "PipeWire configuration complete"
}

configure_pulseaudio() {
    if ! command -v pactl &> /dev/null; then
        echo "Error: pactl not found. Install pulseaudio-utils."
        return 1
    fi

    echo "Configuring PulseAudio for Rodecaster..."

    SINK=$(pactl list sinks short | grep -i rode | awk '{print $2}')
    SOURCE=$(pactl list sources short | grep -i rode | awk '{print $2}')

    if [ -n "$SINK" ]; then
        pactl set-sink-volume "$SINK" 100%
        echo "Set volume for sink: $SINK"
    fi

    if [ -n "$SOURCE" ]; then
        pactl set-source-volume "$SOURCE" 100%
        echo "Set volume for source: $SOURCE"
    fi

    echo "PulseAudio configuration complete"
}

main() {
    echo "=== Rodecaster Pro Configuration ==="

    if ! find_rodecaster_card; then
        echo "Error: Rodecaster not found in system"
        exit 1
    fi

    configure_alsa

    case "$BACKEND" in
        pipewire)
            configure_pipewire
            ;;
        pulseaudio)
            configure_pulseaudio
            ;;
        *)
            echo "Unknown backend: $BACKEND"
            exit 1
            ;;
    esac

    echo "Configuration complete!"
}

main "$@"