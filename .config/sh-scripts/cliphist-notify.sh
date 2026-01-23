# ~/.config/sh-scripts/cliphist-notify.sh

if pgrep -af "cliphist-notify.sh" | grep -qv "$$"; then
    exit 1
fi

MAX_LENGTH=200
last_hash=""

TMP_FILE="/tmp/cliphist-check"

while true; do
    sleep 1

    # Extrae el contenido más reciente en archivo binario
    cliphist list | head -n 1 | cliphist decode > "$TMP_FILE"

    # Verifica si es diferente al anterior (por hash)
    current_hash=$(sha256sum "$TMP_FILE" | cut -d ' ' -f1)

    if [[ "$current_hash" != "$last_hash" ]]; then
        last_hash="$current_hash"

        # Detectar binario
        if file "$TMP_FILE" | grep -qE 'image|bitmap|binary'; then
            notify-send "  Copied to clipboard" "[Binary data]"
        else
            text=$(cat "$TMP_FILE")
            [[ ${#text} -gt $MAX_LENGTH ]] && preview="${text:0:$MAX_LENGTH}..." || preview="$text"
            notify-send "  Copied to clipboard" "$preview"
        fi
    fi
done
