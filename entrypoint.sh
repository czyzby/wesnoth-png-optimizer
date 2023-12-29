#!/bin/bash -l

branch="${3:-master}"
echo "Cloning Wesnoth $branch."
git clone \
    --depth 1 \
    --filter=blob:none \
    --sparse \
    --single-branch --branch $branch \
    -c advice.detachedHead=false \
    https://github.com/wesnoth/wesnoth \
    /wesnoth
(cd /wesnoth && git sparse-checkout set --no-cone utils/woptipng.py)
echo "Wesnoth repository is ready."

# Capturing Python script stdout.
exec 5>&1

echo
echo "Running woptipng with a threshold of $2..."
output=$(
    python /wesnoth/utils/woptipng.py -d $1 --threshold $2 2>&1 | \
    grep --line-buffered -P '^(optimized.*)|(not replacing.*)|(Nothing optimized.*)|(\d+ of \d+ files optimized.*)$' | \
    tee >(cat - >&5)
)

if printf "%s\n" "${output[@]}" | grep -Fxq "Nothing optimized"; then
    echo
    echo "All images are optimized within the given threshold."
    exit 0
else
    echo
    echo "Found unoptimized images above the optimization threshold."
    echo "See the logs from the woptipng tool."
    exit 1
fi
