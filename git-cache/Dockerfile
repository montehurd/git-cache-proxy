FROM nginx:alpine

RUN apk add --no-cache --update \
    git \
    git-daemon \ 
    fcgiwrap \
    spawn-fcgi && \
    mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    rm -f /var/log/nginx/access.log /var/log/nginx/error.log && \
    mkdir -p /repo-cache /etc/git-cache /tmp/git-home /var/run /var/log/git-cache && \
    chown -R nginx:nginx /repo-cache /etc/git-cache /tmp/git-home /var/log/git-cache && \
    chmod 755 /var/log/git-cache && \
    touch /var/log/git-cache/progress.log && \
    chown nginx:nginx /var/log/git-cache/progress.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY git-cache-handler.sh /usr/local/bin/
COPY start.sh /start.sh
COPY git-cache-operation.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/git-cache-operation.sh && \
    chown nginx:nginx /usr/local/bin/git-cache-operation.sh

RUN chmod +x /usr/local/bin/git-cache-handler.sh /start.sh && \
    chown -R nginx:nginx /usr/local/bin/git-cache-handler.sh

VOLUME /repo-cache
EXPOSE 8765

ENV HOME=/tmp/git-home

CMD ["/start.sh"]