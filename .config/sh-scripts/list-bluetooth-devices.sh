# ~/.config/sh-scripts/list-bluetooth-devices.sh

echo "["
first=true
bluetoothctl devices | grep '^Device' | while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d ' ' -f 3-)

    # Escapa comillas si las hay en el nombre
    name=$(echo "$name" | sed 's/"/\\"/g')

    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi

    echo -n "{\"mac\":\"$mac\", \"name\":\"$name\"}"
done
echo "]"

