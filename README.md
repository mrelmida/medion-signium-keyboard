# Medion Signium 14 S1 OLED Linux Keyboard Driver

A custom Linux `serio` kernel driver module to fix the unresponsive internal keyboard on **Medion Signium 14 S1 OLED** laptops (and other models utilizing the `INTC816` or similar Intel HID framework) when running Linux distributions such as Fedora, Debian, or Ubuntu.

## The Problem
On these laptops, the internal keyboard behaves like a legacy PS/2 keyboard but has several firmware issues:
1. **Set 1 scancodes:** The keyboard natively outputs Set 1 scancodes, but the standard Linux driver (`atkbd`) expects Set 2, resulting in scrambled key mappings (e.g. typing `A` registers as `2`).
2. **Inverted Arrow Keys & Right Alt:** The `Up`, `Down`, and `Right` arrow keys, along with the `Right Alt` (AltGr) key, send their press and release codes **completely inverted** in hardware.
3. **Motherboard ACPI Bug:** Without specific boot parameters, the motherboard's buggy ACPI configuration disables the keyboard port (`serio0`) entirely after boot.

## The Solution
This driver (`medion_kbd.ko`) binds directly to the KBD serio port, intercepts the raw Set 1 scancodes, addresses the inverted states/custom modifiers, and reports correct keypresses to the input subsystem.

---

## Installation Instructions

### 1. Configure Kernel Boot Parameters
To prevent the motherboard ACPI from disabling the keyboard port and to ensure we receive raw scancodes, you must add the following parameters to your GRUB configuration:
```text
i8042.nopnp=1 i8042.direct=1
```
On Fedora, you can set this permanently with:
```bash
sudo grubby --update-kernel=ALL --args="i8042.nopnp=1 i8042.direct=1" --remove-args="i8042.unlock=1"
```

### 2. Install Kernel Headers & Build
Ensure you have the development tools and kernel headers installed for your running kernel:
* **Fedora:** `sudo dnf install kernel-devel`
* **Ubuntu/Debian:** `sudo apt install linux-headers-$(uname -r)`

Clone this repository and compile the driver module:
```bash
make
```

### 3. Enroll the MOK Key (For Secure Boot)
If UEFI Secure Boot is active on your laptop, you must sign the driver using a Machine Owner Key (MOK):
1. Run the helper signing script:
   ```bash
   sudo ./sign_module.sh
   ```
2. The script will generate a MOK key pair, sign `medion_kbd.ko`, and ask you to enter a temporary password (e.g., `123456`) to register the MOK.
3. **Reboot your system.**
4. On startup, a blue screen titled **Shim UEFI Key Management** will appear.
5. Select **Enroll MOK** -> **Continue** -> **Yes**, enter the password you set, and select **Reboot**.

### 4. Install & Automate
After enrolling the key (or if Secure Boot is disabled), copy the module to the standard kernel modules directory, register it, and copy the loader scripts:
```bash
# Copy module and update dependencies
sudo mkdir -p /lib/modules/$(uname -r)/extra/
sudo cp medion_kbd.ko /lib/modules/$(uname -r)/extra/
sudo depmod -a

# Install loader script
sudo cp load_kbd_module.sh /usr/local/bin/load_kbd_module.sh
sudo chmod +x /usr/local/bin/load_kbd_module.sh

# Install and enable the boot service
sudo cp medion_kbd.service /etc/systemd/system/medion_kbd.service
sudo systemctl daemon-reload
sudo systemctl enable medion_kbd.service
```

Upon your next boot, the custom driver will automatically load and translate your internal keyboard keys natively!

## License
GPL v2
