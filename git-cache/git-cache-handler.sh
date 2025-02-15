#!/bin/sh -x

# Set thread counts for various Git operations
thread_count=$(getconf _NPROCESSORS_ONLN)
git config --global pack.threads $thread_count
git config --global fetch.parallel $thread_count
git config --global submodule.fetchJobs $thread_count
git config --global grep.threads $thread_count

# Preload index for parallel reads
git config --global core.preloadIndex true

# Set log file path
PROGRESS_LOG=/var/log/git-cache/progress.log

# Convert PATH_INFO back to original URL
# Remove /info/refs and other git suffixes first
CLEAN_PATH=$(echo "$PATH_INFO" | sed -E 's/(\/info\/refs|\/git-upload-pack)$//' | sed 's/^\/*//')
REPO_URL="https://$CLEAN_PATH"

# Use full path structure
REPO_PATH="/repo-cache/$CLEAN_PATH"

# Only do clone/fetch for info/refs requests
if echo "$PATH_INFO" | grep -q "/info/refs$"; then
    if [ ! -d "$REPO_PATH" ]; then
        mkdir -p "$(dirname "$REPO_PATH")"
        echo -e "\nStarting git clone of $REPO_URL" >> $PROGRESS_LOG
        git clone --bare --no-tags --progress "$REPO_URL" "$REPO_PATH" 2>> $PROGRESS_LOG
        echo "Finished git clone" >> $PROGRESS_LOG
    else
        echo -e "\nStarting git fetch of $REPO_URL" >> $PROGRESS_LOG
        cd "$REPO_PATH" && git fetch --no-tags --progress 2>> $PROGRESS_LOG
        echo "Finished git fetch" >> $PROGRESS_LOG
    fi
fi

# Set required vars for git-http-backend
export GIT_PROJECT_ROOT=/repo-cache
export GIT_HTTP_EXPORT_ALL=1
export PATH=/usr/libexec/git-core:$PATH

# Hand off to git-http-backend which implements the server side of 
# git's smart HTTP protocol. This allows git clients to clone/fetch 
# from our cached bare repositories
exec /usr/libexec/git-core/git-http-backend