# Development Rules and Guidelines

## Core Principles

### 1. Use Existing Solutions
- **ALWAYS** check for existing packages before writing new code
- Prefer system packages: `pacman -Ss <package>` on Arch/Omarchy
- Use AUR packages when official repos don't have what we need
- Leverage existing ALSA/PulseAudio/PipeWire tools

### 2. Keep It Simple
- No reinventing the wheel
- Use bash scripts only for glue code
- Leverage existing Linux audio stack (ALSA, PulseAudio, PipeWire)
- Configuration over coding

### 3. Code Organization
- **Maximum file size**: 300-500 lines
- Split large files into modules
- Each module has a single responsibility
- Use descriptive file names

### 4. Minimize Dependencies
- Use tools already in Omarchy base install
- Avoid adding new package dependencies unless absolutely necessary
- Document why each dependency is required

## Technical Standards

### Audio Stack Priority
1. Use existing ALSA USB Audio Class 2.0 driver
2. Configure via standard ALSA tools (`alsactl`, `amixer`)
3. Use PipeWire (Omarchy default) or PulseAudio profiles
4. Leverage `udev` rules for auto-configuration

### Existing Tools to Use
```bash
# Audio Management
alsa-utils      # ALSA configuration tools
pavucontrol     # PulseAudio volume control
pw-cli          # PipeWire CLI tools
wpctl           # WirePlumber control

# USB Management
usbutils        # lsusb and related tools
udev            # Device management rules

# System Integration
systemd         # Service management
```

### File Structure
```
rodecaster-omarchy/
├── scripts/
│   ├── detect.sh        (< 100 lines)
│   ├── configure.sh     (< 200 lines)
│   └── utils.sh         (< 100 lines)
├── config/
│   ├── alsa/           (existing ALSA configs)
│   ├── pipewire/       (existing PipeWire configs)
│   └── udev/           (device rules)
└── docs/
    └── README.md
```

## Development Workflow

### Before Writing Code
1. Check if functionality exists: `pacman -Ss <functionality>`
2. Search AUR: `yay -Ss <functionality>`
3. Check if ALSA/PulseAudio/PipeWire already handles it
4. Look for existing udev rules

### Code Review Checklist
- [ ] No files exceed 500 lines
- [ ] Using existing packages where possible
- [ ] No duplicate functionality
- [ ] Follows Unix philosophy (do one thing well)
- [ ] Uses standard Linux audio tools

## Testing Commands

### Lint and Check
```bash
shellcheck scripts/*.sh     # Bash linting
```

### Audio Testing
```bash
aplay -l                    # List audio devices
arecord -l                  # List recording devices
pactl list sinks            # PulseAudio sinks
pw-dump                     # PipeWire state
```

## Prohibited Practices

### DO NOT
- Write custom USB drivers
- Create new audio frameworks
- Implement audio processing from scratch
- Build configuration GUIs (use existing: pavucontrol, qasmixer)
- Create custom package managers
- Write C/C++ code when bash + existing tools work

### ALWAYS AVOID
- Complex state management (use systemd)
- Custom IPC mechanisms (use D-Bus if needed)
- File watching daemons (use systemd path units)
- Audio format conversion code (use sox, ffmpeg)

## Integration Points

### Use Existing Omarchy Features
- Package management via pacman/yay
- Service management via systemd
- Audio routing via PipeWire/WirePlumber
- Configuration in standard locations (`/etc`, `~/.config`)

### Standard Locations
```bash
/etc/modprobe.d/          # Kernel module options
/etc/udev/rules.d/        # Device rules
/usr/share/alsa/          # ALSA configurations
/etc/pipewire/            # PipeWire configurations
~/.config/pipewire/       # User PipeWire configs
```

## Quick Reference

### Check Before Coding
```bash
# Is there a package?
pacman -Ss rodecaster
pacman -Ss "usb audio"
yay -Ss rodecaster

# Is it already detected?
lsusb | grep -i rode
aplay -l | grep -i rode
pactl list cards | grep -i rode

# Existing configuration?
find /usr/share/alsa -name "*.conf" | xargs grep -l "rode"
find /etc/pipewire -name "*.conf"
```

### Preferred Solutions
| Need | Use | Don't Use |
|------|-----|-----------|
| USB device detection | udev rules | Custom polling daemon |
| Audio routing | PipeWire/PulseAudio | Custom ALSA programming |
| Configuration | YAML/INI files | Custom formats |
| Service management | systemd units | Init scripts |
| Audio mixing | pw-cli, pactl | Custom mixer code |
| Device permissions | udev + groups | setuid binaries |

## Performance Guidelines

- Startup time: < 1 second
- Use lazy loading where possible
- No polling loops (use events)
- Minimal background processes

## Documentation Requirements

Every script must have:
```bash
#!/bin/bash
# Purpose: One line description
# Dependencies: List required packages
# Usage: script.sh [options]
```

## Version Control

- Commit message format: `type: description`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`
- Keep commits atomic and focused
- Reference existing tools in commit messages

---

Remember: The best code is no code. The second best is code that uses what already exists.