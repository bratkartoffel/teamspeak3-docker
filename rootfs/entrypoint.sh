#!/bin/ash

# exit when any command fails
set -o errexit -o pipefail

# configuration
: "${APP_UID:=506}"
: "${APP_GID:=506}"
: "${APP_UMASK:=027}"
: "${APP_USER:=teamspeak3}"
: "${APP_GROUP:=teamspeak3}"
: "${APP_HOME:=/var/lib/ts3server}"
: "${APP_CONF_FILE:=${APP_HOME}/ts3server.ini}"
: "${APP_ADDITIONAL_PARAMS:=}"

# export configuration
export APP_HOME APP_CONF_FILE APP_ADDITIONAL_PARAMS

# invoked as root, add user and prepare container
if [ "$(id -u)" -eq 0 ]; then
  echo ">> removing default user and group ($APP_USER)"
  if getent passwd "$APP_USER" >/dev/null; then deluser "$APP_USER"; fi
  if getent group "$APP_GROUP" >/dev/null; then delgroup "$APP_GROUP"; fi

  echo ">> adding unprivileged user (uid: $APP_UID / gid: $APP_GID)"
  addgroup -g "$APP_GID" "$APP_GROUP"
  adduser -HD -h "$APP_HOME" -s /sbin/nologin -G "$APP_GROUP" -u "$APP_UID" -k /dev/null "$APP_USER"

  echo ">> fixing permissions"
  install -dm 0750 -o "$APP_USER" -g "$APP_GROUP" "$APP_HOME"
  chown -R "$APP_USER":"$APP_GROUP" \
          "$APP_HOME" \
          /opt/ts3server \
          /etc/s6

  echo ">> create link for syslog redirection"
  install -dm 0750 -o "$APP_USER" -g "$APP_GROUP" /run/syslogd
  [[ -h /dev/log ]] && rm -v /dev/log
  ln -sfv /run/syslogd/syslogd.sock /dev/log

  # drop privileges and re-execute this script unprivileged
  echo ">> dropping privileges"
  export HOME="$APP_HOME" USER="$APP_USER" LOGNAME="$APP_USER" PATH="/usr/local/bin:/bin:/usr/bin"
  exec /bin/setpriv --reuid="$APP_USER" --regid="$APP_GROUP" --init-groups --inh-caps=-all "$0" "$@"
fi

# tighten umask for newly created files / dirs
echo ">> changing umask to $APP_UMASK"
umask "$APP_UMASK"

echo ">> starting application"
exec /usr/bin/s6-svscan /etc/s6

# vim: set ft=bash ts=2 sts=2 expandtab:

