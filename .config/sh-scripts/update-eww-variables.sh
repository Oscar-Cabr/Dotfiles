# ~/.config/sh-scripts/update-eww-variables.sh

while true; do
    eww update BLUETOOTH_DEVICES="$(./list-bluetooth-devices.sh)"
    sleep 10
done
