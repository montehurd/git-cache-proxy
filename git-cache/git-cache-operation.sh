#!/bin/sh

set -e

REPO_PATH="$1"
REPO_URL="$2"
PROGRESS_LOG="$3"

start=$(date +%s)

if [ ! -d "$REPO_PATH" ]; then
   echo -e "\nStarting cache git clone of '$REPO_URL'" >> "$PROGRESS_LOG"
   git clone --bare --progress "$REPO_URL" "$REPO_PATH" 2>> "$PROGRESS_LOG"
   echo "Finished cache git clone" >> "$PROGRESS_LOG"
else
   echo -e "\nStarting cache git fetch of '$REPO_URL'" >> "$PROGRESS_LOG"
   # A bare clone has no fetch refspec, so a plain fetch would only update FETCH_HEAD.
   # Branches and tags only: Gerrit also advertises a ref for every patch set.
   cd "$REPO_PATH" && git fetch --prune --progress origin '+refs/heads/*:refs/heads/*' '+refs/tags/*:refs/tags/*' 2>> "$PROGRESS_LOG"
   echo "Finished cache git fetch" >> "$PROGRESS_LOG"
fi

end=$(date +%s)

echo "Duration: $((end - start)) seconds" >> "$PROGRESS_LOG"