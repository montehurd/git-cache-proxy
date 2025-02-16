#!/bin/sh

set -e

REPO_PATH="$1"
REPO_URL="$2"
PROGRESS_LOG="$3"

if [ ! -d "$REPO_PATH" ]; then
    echo -e "\nStarting cache git clone of $REPO_URL" >> "$PROGRESS_LOG"
    start=$(date +%s)
    git clone --bare --no-tags --progress "$REPO_URL" "$REPO_PATH" 2>> "$PROGRESS_LOG"
    end=$(date +%s)
    echo "Finished cache git clone (took $((end - start)) seconds)" >> "$PROGRESS_LOG"
else
    echo -e "\nStarting cache git fetch of $REPO_URL" >> "$PROGRESS_LOG"
    start=$(date +%s)
    cd "$REPO_PATH" && git fetch --no-tags --progress 2>> "$PROGRESS_LOG"
    end=$(date +%s)
    echo "Finished cache git fetch (took $((end - start)) seconds)" >> "$PROGRESS_LOG"
fi