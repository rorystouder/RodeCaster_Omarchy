# Rodecaster Pro Omarchy Deployment Guide

Complete step-by-step deployment instructions from repository clone to working audio interface.

## Pre-Deployment Requirements

### System Requirements
- Omarchy Linux or Arch Linux installation
- Root/sudo access
- Active internet connection for package downloads
- USB 2.0/3.0 port available

### Hardware Requirements
- Rodecaster Pro or Rodecaster Pro II
- USB-C to USB-A cable (included with device)
- Headphones or speakers for testing

## Step 1: System Preparation

### 1.1 Update System
```bash
sudo pacman -Syu
```

### 1.2 Verify Audio Subsystem
```bash
# Check if PipeWire is running (Omarchy default)
systemctl --user status pipewire pipewire-pulse

# OR check if PulseAudio is running
systemctl --user status pulseaudio

# Verify ALSA is available
ls /proc/asound/
```

### 1.3 Add User to Audio Group
```bash
sudo usermod -a -G audio $USER
# Log out and back in for group changes to take effect
```

## Step 2: Clone Repository

### 2.1 Install Git (if needed)
```bash
sudo pacman -S git
```

### 2.2 Clone the Repository
```bash
cd ~
git clone https://github.com/rorystouder/RodeCaster_Omarchy.git
cd RodeCaster_Omarchy
```

### 2.3 Verify Repository Contents
```bash
ls -la
# Should see: install.sh, scripts/, config/, README.md, etc.
```

## Step 3: Pre-Installation Checks

### 3.1 Check USB Ports
```bash
# List USB controllers
lspci | grep USB

# Check for AMD controllers (potential issues)
lspci | grep USB | grep AMD
```

### 3.2 Test Script Permissions
```bash
# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh

# Verify
ls -l scripts/
```

## Step 4: Installation

### 4.1 Run Installer
```bash
sudo ./install.sh
```

Expected output:
```
[INFO] === Rodecaster Pro Omarchy Integration Installer ===
[INFO] Checking for required packages...
[INFO] Installing scripts...
[INFO] Scripts installed to /usr/local/bin/
[INFO] Installing configuration files...
[INFO] Configuration files installed
[INFO] Reloading services...
[INFO] Services reloaded
[INFO] === Installation Complete ===
```

### 4.2 Verify Installation
```bash
# Check installed scripts
which rodecaster-detect
which rodecaster-configure

# Check udev rules
ls -l /etc/udev/rules.d/99-rodecaster.rules

# Check ALSA config
ls -l /usr/share/alsa/cards/rodecaster.conf

# Check PipeWire config (if using PipeWire)
ls -l /etc/pipewire/pipewire.conf.d/rodecaster.conf
```

## Step 5: Connect Rodecaster Pro

### 5.1 Physical Connection
1. Power on Rodecaster Pro
2. Wait for boot sequence (LED indicators stable)
3. Connect USB-C cable to USB 1 port on Rodecaster
4. Connect USB-A end to computer
5. Prefer USB 2.0 or USB 3.0 ports (avoid USB 3.2)
6. Avoid AMD USB controllers if possible

### 5.2 Verify Detection
```bash
# Check USB connection
lsusb | grep -i rode
# Should show: Bus xxx Device xxx: ID 19f7:0015 RODE Microphones RODECaster Pro II

# Run detection script
rodecaster-detect
```

Expected output:
```
=== Rodecaster Pro Detection ===
Found: Rodecaster Pro (USB ID: 19f7:0015)
✓ USB device detected
Found: Rodecaster on ALSA card 2
✓ ALSA device detected
```

## Step 6: Configure Audio

### 6.1 Automatic Configuration
If udev rules are working, configuration happens automatically on connection.

Verify with:
```bash
# Check system logs
journalctl -f
# Connect device and watch for configuration messages
```

### 6.2 Manual Configuration
```bash
# For PipeWire (Omarchy default)
rodecaster-configure

# For PulseAudio
rodecaster-configure pulseaudio
```

Expected output:
```
=== Rodecaster Pro Configuration ===
Found card: RODECasterProII
Configuring ALSA for RODECasterProII...
ALSA configuration complete
Configuring PipeWire for Rodecaster...
PipeWire configuration complete
Configuration complete!
```

## Step 7: Verify Functionality

### 7.1 Check ALSA Recognition
```bash
# List playback devices
aplay -l | grep -i rode

# List capture devices
arecord -l | grep -i rode

# Show card details
cat /proc/asound/cards | grep -i rode
```

### 7.2 Check PipeWire/PulseAudio
```bash
# For PipeWire
pw-cli ls Node | grep -i rode
wpctl status | grep -i rode

# For PulseAudio
pactl list sinks | grep -i rode
pactl list sources | grep -i rode
```

### 7.3 Test Audio Playback
```bash
# Generate test tone
speaker-test -c 2 -r 48000 -F S24_3LE

# Play audio file
aplay -D hw:RODECasterProII test.wav
```

### 7.4 Test Audio Recording
```bash
# Record 5 seconds of audio
arecord -d 5 -f S24_3LE -r 48000 test-recording.wav

# Play back recording
aplay test-recording.wav
```

## Step 8: Application Configuration

### 8.1 Set as Default Device
```bash
# PipeWire
wpctl set-default $(wpctl status | grep -i rode | awk '{print $1}' | tr -d '.')

# PulseAudio
pactl set-default-sink $(pactl list sinks short | grep -i rode | awk '{print $2}')
pactl set-default-source $(pactl list sources short | grep -i rode | awk '{print $2}')
```

### 8.2 GUI Configuration
```bash
# Open audio control panel
pavucontrol  # Works with both PipeWire and PulseAudio
```

1. Go to "Configuration" tab
2. Select "Rodecaster Pro II"
3. Choose profile: "Digital Stereo (IEC958) Output + Input"
4. Go to "Input Devices" and "Output Devices" to adjust levels

## Step 9: Persistence Check

### 9.1 Test Reconnection
1. Disconnect USB cable
2. Wait 5 seconds
3. Reconnect USB cable
4. Run `rodecaster-detect`
5. Verify audio still works

### 9.2 Test Reboot
```bash
sudo reboot
```

After reboot:
1. Log in
2. Connect Rodecaster Pro
3. Run `rodecaster-detect`
4. Test audio playback/recording

## Troubleshooting

### Device Not Detected

1. **Try different USB port**
```bash
# List all USB devices
lsusb -t
```

2. **Check dmesg for errors**
```bash
sudo dmesg | tail -50
```

3. **Reset USB subsystem**
```bash
sudo modprobe -r snd_usb_audio
sudo modprobe snd_usb_audio
```

### Audio Format Errors

1. **Force 48kHz/24-bit**
```bash
# Edit ~/.asoundrc
echo "defaults.pcm.rate_converter \"samplerate_best\"
defaults.pcm.dmix.rate 48000
defaults.pcm.dmix.format S24_3LE" > ~/.asoundrc
```

2. **Restart audio services**
```bash
systemctl --user restart pipewire pipewire-pulse
# OR
systemctl --user restart pulseaudio
```

### AMD USB Controller Issues

1. **Identify USB controllers**
```bash
lspci | grep USB
```

2. **Use non-AMD port or install PCIe USB card**

3. **Force USB 2.0 mode**
```bash
# Add to /etc/modprobe.d/usb-quirks.conf
echo "options usbcore quirks=19f7:0015:u" | sudo tee /etc/modprobe.d/usb-quirks.conf
```

### No Sound Output

1. **Check volume levels**
```bash
alsamixer -c RODECasterProII
# Use arrows to adjust, ESC to exit
```

2. **Unmute channels**
```bash
amixer -c RODECasterProII set Master unmute
amixer -c RODECasterProII set PCM unmute
```

3. **Check routing**
```bash
# PipeWire
pw-top  # Monitor real-time audio flow

# PulseAudio
pavucontrol  # Check application routing
```

## Verification Checklist

- [ ] System updated
- [ ] Repository cloned
- [ ] Installation completed without errors
- [ ] Rodecaster detected via USB
- [ ] ALSA recognizes device
- [ ] PipeWire/PulseAudio sees device
- [ ] Audio playback works
- [ ] Audio recording works
- [ ] Device persists after reconnection
- [ ] Device works after reboot

## Quick Test Commands

```bash
# One-line detection test
lsusb | grep -i rode && echo "✓ USB OK" || echo "✗ USB Failed"

# One-line ALSA test
aplay -l | grep -i rode && echo "✓ ALSA OK" || echo "✗ ALSA Failed"

# One-line audio test (requires sox)
sudo pacman -S sox
play -n synth 1 sine 440 && echo "✓ Audio OK" || echo "✗ Audio Failed"
```

## Uninstallation

If you need to remove the integration:

```bash
# Remove scripts
sudo rm /usr/local/bin/rodecaster-detect
sudo rm /usr/local/bin/rodecaster-configure

# Remove configs
sudo rm /etc/udev/rules.d/99-rodecaster.rules
sudo rm /usr/share/alsa/cards/rodecaster.conf
sudo rm /etc/pipewire/pipewire.conf.d/rodecaster.conf

# Reload services
sudo udevadm control --reload-rules
systemctl --user restart pipewire pipewire-pulse
```

## Support

### Logs Location
- System logs: `journalctl -xe`
- PipeWire logs: `journalctl --user -u pipewire`
- ALSA info: `alsa-info.sh`

### Debug Mode
```bash
# Run with debug output
ALSA_CARD=RODECasterProII alsactl -v restore

# PipeWire debug
PIPEWIRE_DEBUG=3 pipewire
```

### Getting Help
1. Check `rodecaster-detect` output
2. Review system logs
3. Verify all installation steps
4. Check hardware connections
5. Consult README.md troubleshooting section

---

## Success Indicators

When everything is working correctly:
1. Rodecaster LED shows USB connection active
2. `lsusb` shows RODE device
3. Audio applications list Rodecaster as option
4. Sound plays through Rodecaster outputs
5. Rodecaster inputs record successfully
6. No errors in system logs

Deployment complete! Your Rodecaster Pro should now be fully functional on Omarchy Linux.