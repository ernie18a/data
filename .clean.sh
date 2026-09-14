#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="/g/data"
OUTPUT_DIR="/g/data/OUTPUT"

TS_PATTERN='s/^[[:space:]]*\[[[:space:]]*[0-9][0-9]*\(\.[0-9]*\)\?s[[:space:]]*->[[:space:]]*[0-9][0-9]*\(\.[0-9]*\)\?s\][[:space:]]*//'
VTT_PATTERN='s/^[[:space:]]*[0-9][0-9]*:[0-9][0-9]:[0-9][0-9]\.[0-9]*[[:space:]]*-->[[:space:]]*[0-9][0-9]*:[0-9][0-9]:[0-9][0-9]\.[0-9]*[[:space:]]*//'
SRT_IDX_PATTERN='/^[[:space:]]*[0-9][0-9]*[[:space:]]*$/d'
WEBVTT_HEADER_PATTERN='/^WEBVTT/d'
BLANK_COLLAPSE_PATTERN='/^[[:space:]]*$/d'

process_file() {
    local src="$1"
    local rel="${src#"$SOURCE_ROOT"/}"
    local dst="$OUTPUT_DIR/$rel"
    local tmp_file
    tmp_file="$(dirname "$dst")/.$(basename "$dst").tmp"

    mkdir -p "$(dirname "$dst")"
    sed \
        -e "$TS_PATTERN" \
        -e "$VTT_PATTERN" \
        -e "$SRT_IDX_PATTERN" \
        -e "$WEBVTT_HEADER_PATTERN" \
        -e "$BLANK_COLLAPSE_PATTERN" \
        "$src" > "$tmp_file"
    mv "$tmp_file" "$dst"
}

export -f process_file
export SOURCE_ROOT OUTPUT_DIR
export TS_PATTERN VTT_PATTERN SRT_IDX_PATTERN WEBVTT_HEADER_PATTERN BLANK_COLLAPSE_PATTERN

TARGET_CPU=85
NPROC=$(nproc)
JOBS=$(( NPROC * TARGET_CPU / 100 ))
JOBS=$(( JOBS < 1 ? 1 : JOBS ))

mkdir -p "$OUTPUT_DIR"

find "$SOURCE_ROOT"/*/ -type f \( -name "*.txt" -o -name "*.vtt" -o -name "*.srt" \) -print0 \
    | xargs -0 -P "$JOBS" -I{} bash -c 'process_file "$@"' _ {}

echo "Done. Output: $OUTPUT_DIR"
