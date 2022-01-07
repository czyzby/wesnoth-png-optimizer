#!/bin/bash -l

# Capturing Python script stdout.
exec 5>&1

echo "Running woptipng."
output=$(python /wesnoth/utils/woptipng.py . --threshold $1 2>&1 | tee >(cat - >&5))

if printf "%s\n" "${output[@]}" | grep -Fxq "Nothing optimized"; then
    exit 0
else
    echo "Found unoptimized images above the optimization threshold."
    echo "See the logs from the woptipng tool."
    exit 1
fi
