#!/bin/sh
# Shell script for running the proxy service

#If any part of the next steps fail, fail the entire script
set -e
# Environment substitute - pipe in the template file and substitute with environment variable with matching name
# This is how you pass in configuration values at run time when you run the server
envsubst < /etc/nginx/default.conf.tpl > /etc/nginx/conf.d/default.conf
# Start nginx with the configuration file, daemon off runs it in the foreground since we are running it in Docker
nginx -g 'daemon off;'
