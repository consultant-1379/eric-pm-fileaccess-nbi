#!/bin/sh

SCRIPT_NAME=$(basename "${0}")
_LOGGER=/bin/logger
LOG_TAG="container-prestop-hook"

info() {
  $_LOGGER -s -t ${LOG_TAG} -p user.notice "INFO ${SCRIPT_NAME}: $*"
}

error() {
  $_LOGGER -s -t ${LOG_TAG} -p user.err "ERROR ${SCRIPT_NAME}: $*"
}

X=0
while true; do
  metric=$(curl -s localhost:9600/metrics | grep 'apache_workers{state="busy"}')
  busy_workers=$(echo "$metric" | grep -oP 'apache_workers\{.*\} \K\d+')
  if [ -n "$busy_workers" ]; then
    X=$X+1
    if [ "$busy_workers" -gt 1 ]; then
      if [ $((X % 6)) -eq 0 ]; then
        info "The Apache Server is busy handling requests with $busy_workers workers."
      fi
      sleep 3
    else
      info "The Apache Server is ready for shutdown..."
      /usr/sbin/apachectl -d /etc/httpd/ -f conf/httpd.conf -e info -k stop
      break
    fi
  else
    error "Could not retrieve Apache Server Status"
    break
  fi
done