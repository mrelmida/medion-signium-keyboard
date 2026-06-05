#!/bin/bash
set -e

# 1. Generate MOK key pair if not exists
if [ ! -f MOK.priv ] || [ ! -f MOK.der ]; then
    echo "Generating MOK key pair..."
    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=Medion Keyboard MOK/"
fi

# 2. Sign the module
echo "Signing medion_kbd.ko..."
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 MOK.priv MOK.der medion_kbd.ko

# 3. Enroll the key if not already enrolled or queued
if sudo mokutil --test-key MOK.der 2>&1 | grep -q "is enrolled"; then
    echo "MOK key is already enrolled."
else
    echo "Registering MOK key with mokutil..."
    echo -e "123456\n123456" | sudo mokutil --import MOK.der
    echo "MOK registration completed. Password set to: 123456"
    echo "IMPORTANT: You must reboot your laptop now."
    echo "On reboot, the blue MOK Manager screen will appear."
    echo "Choose: Enroll MOK -> Continue -> Yes -> Enter password '123456' -> Reboot."
fi
