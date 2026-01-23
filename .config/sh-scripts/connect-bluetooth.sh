# ~/.config/sh-scripts/connect-bluetooth.sh

# $1 = device number (1-based index)
index=${1:-1}

bluetoothDevice=$(bluetoothctl devices | awk '{print $3,$4,$5}' | sed -n "${index}p")
bluetoothDeviceMAC=$(bluetoothctl devices | awk '{print $2}' | sed -n "${index}p")

# Conexión
bluetoothctl connect "$bluetoothDeviceMAC"

# Salida (opcional)
echo "$bluetoothDevice $bluetoothDeviceMAC"
