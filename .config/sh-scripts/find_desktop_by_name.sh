#!/bin/bash
# To use it, execute ./find_desktop_by_name.sh Name
# Where "Name" is the name of the application that appears when wofi is opened
if [[ -z "$1" ]]; then
  echo "Uso: $0 <nombre_a_buscar>"
  echo "Ejemplo: $0 firefox"
  exit 1
fi

SEARCH_TERM="$1"
FOUND=false

echo "🔍 Buscando coincidencias con: \"$SEARCH_TERM\" ..."
echo

while IFS= read -r file; do
  name_line=$(grep -m1 '^Name=' "$file" 2>/dev/null)
  [[ -z "$name_line" ]] && continue

  name_value="${name_line#Name=}"

  if [[ "${name_value,,}" == *"${SEARCH_TERM,,}"* ]]; then
    FOUND=true
    printf "📄 %-40s → \"%s\"\n" "$(basename "$file")" "$name_value"
  fi
done < <(find /usr/share/applications -type f -name '*.desktop' 2>/dev/null | sort)

if ! $FOUND; then
  echo "⚠️  No se encontraron coincidencias."
fi
