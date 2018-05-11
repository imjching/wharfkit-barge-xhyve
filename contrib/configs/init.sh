#!/bin/sh

LOOPBACK_IP=127.0.1.1
HOSTNAME=$(cat /proc/cmdline | sed -n 's/^.*barge.hostname="\([^"]\+\)".*$/\1/p')
PREV_HOSTNAME=$(cat /etc/hostname)

# Ensures that hostname is present and different from previous.
if [[ $HOSTNAME ]] && [ "$HOSTNAME" != "$PREV_HOSTNAME" ]; then
  # Update hostname
  echo "$HOSTNAME" | sudo tee /etc/hostname > /dev/null

  # Remove old hosts entry.
  sed -i "/$(echo -e "$LOOPBACK_IP\t$PREV_HOSTNAME")/d" /etc/hosts

  # Add new hosts entry if entry is missing.
  HOSTS_ENTRY=$(echo -e "$LOOPBACK_IP\t$HOSTNAME")
  if ! grep -q "$HOSTS_ENTRY" /etc/hosts; then
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
  fi
fi
