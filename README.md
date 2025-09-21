# Rodecaster Pro Integration for Omarchy Linux

Minimal integration for Rodecaster Pro/Pro II on Omarchy Linux using standard Linux audio tools.

## Philosophy

- Uses existing Linux audio stack (ALSA, PipeWire)
- No custom drivers or complex software
- Leverages standard tools available in Omarchy
- Configuration-based approach

## Requirements

- Omarchy Linux (or Arch-based distribution)
- Rodecaster Pro or Pro II
- USB 2.0/3.0 port (preferably non-AMD chipset)

## Installation

```bash
sudo ./install.sh
```

This installs:
- Detection and configuration scripts
- udev rules for auto-configuration
- ALSA and PipeWire configurations

## Usage

### Detection
```bash
rodecaster-detect
```

### Manual Configuration
```bash
rodecaster-configure          # Uses PipeWire (Omarchy default)
rodecaster-configure pulseaudio  # Use PulseAudio backend
```

### Automatic Configuration
Device is automatically configured when connected (via udev rules).

## Troubleshooting

### USB Issues
If device not detected:
1. Try different USB port
2. Use USB 2.0 port if available
3. Consider PCIe USB card for AMD systems

### Audio Format
Rodecaster requires:
- Sample rate: 48000 Hz
- Bit depth: 24-bit
- Format: S24_3LE

### Check Status
```bash
# ALSA
aplay -l | grep -i rode
arecord -l | grep -i rode

# PipeWire
pw-cli ls Node | grep -i rode
wpctl status | grep -i rode

# USB
lsusb | grep -i rode
```

## Files

```
scripts/
├── detect.sh        # Device detection
├── configure.sh     # Configuration script
└── utils.sh         # Utility functions

config/
├── udev/           # Auto-configuration rules
├── alsa/           # ALSA configurations
└── pipewire/       # PipeWire configurations
```

## Known Issues

1. **AMD USB Controllers**: May have compatibility issues
   - Solution: Use Intel USB ports or PCIe USB card

2. **USB 3.2**: Some incompatibility reported
   - Solution: Use USB 2.0 or 3.0 ports

3. **Dual Interface**: Second USB interface may not appear
   - Solution: Check PipeWire/ALSA configuration

## Contributing

Follow guidelines in CLAUDE.md:
- Use existing tools
- Keep scripts under 500 lines
- Test on real Omarchy system

## License

MIT License - See LICENSE file