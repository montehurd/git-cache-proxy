#!/bin/sh
set -x

# Spawn multiple FCGI workers based on CPU count
worker_count=$(getconf _NPROCESSORS_ONLN)
spawn-fcgi -u nginx -g nginx -s /var/run/fcgiwrap.socket -U nginx -G nginx -P /var/run/fcgiwrap.pid -F $worker_count -- /usr/bin/fcgiwrap

chmod 660 /var/run/fcgiwrap.socket
chown nginx:nginx /var/run/fcgiwrap.socket

exec nginx