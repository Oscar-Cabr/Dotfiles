# ~/.config/sh-scripts/wofi-toggle-display.sh

# Execute as: ./wofi-toggle-display.sh* --hide
# or: ./wofi-toggle-display.sh* --show

# Ruta base local
LOCAL_DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$LOCAL_DESKTOP_DIR"

# Función para ocultar entradas de blacklist
hide_entries() {
  echo "📁 Ocultando entradas listadas en blacklist.txt"
  while IFS= read -r entry || [[ -n "$entry" ]]; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    src=$(find /usr/share/applications -name "$entry" 2>/dev/null | head -n 1)
    if [[ -z "$src" ]]; then
      echo "⚠️  No encontrado: $entry"
      continue
    fi
    cp "$src" "$LOCAL_DESKTOP_DIR/$entry"
    sed -i '/^NoDisplay=/d' "$LOCAL_DESKTOP_DIR/$entry"
    echo "NoDisplay=true" >> "$LOCAL_DESKTOP_DIR/$entry"
    echo "🔕 Ocultado: $entry"
  done < "blacklist.txt"
}

# Función para mostrar entradas de whitelist
show_entries() {
  echo "📁 Mostrando entradas listadas en whitelist.txt"
  while IFS= read -r entry || [[ -n "$entry" ]]; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    file="$LOCAL_DESKTOP_DIR/$entry"
    if [[ ! -f "$file" ]]; then
      echo "⚠️  No existe localmente: $entry"
      continue
    fi
    sed -i '/^NoDisplay=/d' "$file"
    echo "🔔 Mostrado: $entry"
  done < "whitelist.txt"
}

# Entrada del script
case "$1" in
  --hide)
    hide_entries
    ;;
  --show)
    show_entries
    ;;
  *)
    echo "Uso: $0 --hide | --show"
    echo "  --hide  : Oculta las entradas en blacklist.txt"
    echo "  --show  : Muestra las entradas en whitelist.txt"
    exit 1
    ;;
esac

echo -e "\n✅ Operación completada. Reinicia Wofi si está abierto."

