#!/usr/bin/env bash

TEMPLATE="$HOME/Documents/Notas/template.fnx"

tmpfile="$(mktemp --suffix=.fnx)"
cp "$TEMPLATE" "$tmpfile"
feathernotes "$tmpfile"
