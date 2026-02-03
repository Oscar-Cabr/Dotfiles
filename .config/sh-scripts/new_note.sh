#!/usr/bin/env bash

NOTES_DIR="$HOME/Documents/Notas/"
TEMPLATE="$NOTES_DIR/template.fnx"

timestamp="$(date +"%Y-%m-%d_%H%M%S")"
note_file="$NOTES_DIR/FeatherNote_$timestamp.fnx"

cp "$TEMPLATE" "$note_file"
feathernotes "$note_file"
