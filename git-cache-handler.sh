#!/bin/sh -x

exec 2>/var/log/git-cache/handler.log

# Set all required vars
export GIT_PROJECT_ROOT=/repo-cache
export GIT_HTTP_EXPORT_ALL=1
export PATH=/usr/libexec/git-core:$PATH

# Convert PATH_INFO back to original URL
# Remove /info/refs and other git suffixes first
CLEAN_PATH=$(echo "$PATH_INFO" | sed -E 's/(\/info\/refs|\/git-upload-pack)$//' | sed 's/^\/*//')
REPO_URL="https://$CLEAN_PATH"

# Use full path structure
REPO_PATH="/repo-cache/$CLEAN_PATH"

if [ ! -d "$REPO_PATH" ]; then
    mkdir -p "$(dirname "$REPO_PATH")"
    git clone --bare --no-tags "$REPO_URL" "$REPO_PATH"
else
    cd "$REPO_PATH" && git fetch --no-tags
fi

# start git-http-backend
exec /usr/libexec/git-core/git-http-backend