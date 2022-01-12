#!/bin/bash -l

echo "Cloning Wesnoth ${3:-master}."
git clone \
    --depth 1 \
    --filter=blob:none \
    --sparse \
    --single-branch --branch ${3:-master} \
    -c advice.detachedHead=false \
    https://github.com/wesnoth/wesnoth \
    /wesnoth
(cd /wesnoth && git sparse-checkout set utils/woptipng.py)

# Capturing Python script stdout.
exec 5>&1

echo "Running woptipng with $2 threshold."
output=$(python /wesnoth/utils/woptipng.py -d $1 --threshold $2 2>&1 | tee >(cat - >&5))

if printf "%s\n" "${output[@]}" | grep -Fxq "Nothing optimized"; then
    exit 0
else
    echo "Found unoptimized images above the optimization threshold."
    echo "See the logs from the woptipng tool."
    exit 1
fi
