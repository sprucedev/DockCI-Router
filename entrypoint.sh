#!/bin/bash
set -e

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"

if [[ -x "$THIS_DIR/pre-entry.sh" ]]; then
  echo "Sourcing pre-entry script" >&2
  source "$THIS_DIR/pre-entry.sh"
else
  echo "Skipping pre-entry script" >&2
fi
function nginxtest {
  TMP_NGINX="$(mktemp)"
  # Replaces hosts to fake the DNS lookup check
  awk '/proxy_pass|proxy_redirect/{sub(/(dockci|logserve|rabbitmq):/, "localhost:", $0)}{print}' /etc/nginx/nginx.conf > "$TMP_NGINX"
  /usr/sbin/nginx -t -c "$TMP_NGINX"
}
function ci {
  nginxtest
}
function run {
  TMP_NGINX="$(mktemp)"
  dockci_url="${DOCKCI_PORT_5000_TCP_ADDR:-dockci}:${DOCKCI_PORT_5000_TCP_PORT:-5000}"
  rabbitmq_url="${RABBITMQ_PORT_15674_TCP_ADDR:-rabbitmq}:${RABBITMQ_PORT_15674_TCP_PORT:-15674}"
  logserve_url="${LOGSERVE_PORT_8080_TCP_ADDR:-logserve}:${LOGSERVE_PORT_8080_TCP_PORT:-8080}"
  awk "/proxy_pass|proxy_redirect/{sub(/dockci:5000/, \"$dockci_url\", \$0)}{print}" /etc/nginx/nginx.conf |
  awk "/proxy_pass|proxy_redirect/{sub(/rabbitmq:15674/, \"$rabbitmq_url\", \$0)}{print}" |
  awk "/proxy_pass|proxy_redirect/{sub(/logserve:8080/, \"$logserve_url\", \$0)}{print}" > "$TMP_NGINX"

  /usr/sbin/nginx -c "$TMP_NGINX"
}

case "$1" in
  nginxtest|ci|run) "$1" ;;
  *) "$@" ;;
esac
