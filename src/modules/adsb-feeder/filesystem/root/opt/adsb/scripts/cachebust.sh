#!/bin/bash

set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR

# ignore woff2 files they should not change anyhow, this makes this code simpler as the woff2 files
# are referred to from a css file
STATIC="$(find /opt/adsb/adsb-setup/static/ -type f |  grep -v -e '\.License$' -e '\.ico$' -e '\.map$' -e '\.woff2$')"

sedreplaceargs=()

while read -r FILE; do
    md5sum=$(md5sum "$FILE" | cut -d' ' -f1)
    dir="$(dirname $FILE)"
    base="$(basename $FILE)"
    prefix="${base%.*}"
    postfix="${base##*.}"
    newname="${prefix}.${md5sum}.${postfix}"
    mv "$FILE" "$dir/$newname"
    sedreplaceargs+=("-e" "s#${base}#${newname}#")
done <<< "$STATIC"

#echo "${sedreplaceargs[@]}"
for FILE in /opt/adsb/adsb-setup/templates/*.html; do
    sed -i "${sedreplaceargs[@]}" "$FILE"
done
