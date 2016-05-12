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
  awk '/proxy_pass|proxy_redirect/{sub(/(dockci|dockci-logserve|dockci-rabbit):/, "localhost:", $0)}{print}' nginx.conf > "$TMP_NGINX"
  /usr/sbin/nginx -t -c "$TMP_NGINX"
}
function ci {
  nginxtest
}
function run {
  /usr/sbin/nginx -c "/etc/nginx/nginx.conf"
}

case "$1" in
  nginxtest|ci|run) "$1" ;;
  *) "$@" ;;
esac
