#!/bin/sh
# Load custom keyboard driver and bind to serio0
modprobe medion_kbd
echo -n "none" > /sys/bus/serio/devices/serio0/drvctl
echo -n "medion_kbd" > /sys/bus/serio/devices/serio0/drvctl
