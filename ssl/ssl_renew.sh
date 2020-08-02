#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
FILENAME="-f docker-compose.full-stack.yml"
DOCKER="/usr/bin/docker"

cd /home/user_stories/wysiblocks-production/
$COMPOSE $FILENAME run certbot renew && $COMPOSE $FILENAME kill -s SIGHUP reverse-proxy
$DOCKER system prune -af