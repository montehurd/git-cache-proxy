#!/bin/sh
set -x

thread_count=$(getconf _NPROCESSORS_ONLN)

# Set thread counts for various Git operations. Set once here rather than per
# request: concurrent requests rewriting the config race on its lock file, and
# the losers fail with a 502
git config --system pack.threads $thread_count
git config --system fetch.parallel $thread_count
git config --system submodule.fetchJobs $thread_count
git config --system grep.threads $thread_count
git config --system pack.readThreads $thread_count
git config --system pack.writeThreads $thread_count

# Spawn multiple FCGI workers based on CPU count
worker_count=$thread_count
spawn-fcgi -u nginx -g nginx -s /var/run/fcgiwrap.socket -U nginx -G nginx -P /var/run/fcgiwrap.pid -F $worker_count -- /usr/bin/fcgiwrap

chmod 660 /var/run/fcgiwrap.socket
chown nginx:nginx /var/run/fcgiwrap.socket

exec nginx