#!/bin/sh
set -x

spawn-fcgi -u nginx -g nginx -s /var/run/fcgiwrap.socket -U nginx -G nginx -P /var/run/fcgiwrap.pid -- /usr/bin/fcgiwrap

chmod 660 /var/run/fcgiwrap.socket
chown nginx:nginx /var/run/fcgiwrap.socket

exec nginx