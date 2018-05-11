#!/bin/sh

GW_IP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $3}')

if ! grep -q sntp /etc/cron/crontabs/root; then
  if [ -n "${GW_IP}" ]; then
    echo '*/5 * * * * /usr/bin/sntp -4sSc' "${GW_IP}" >> /etc/cron/crontabs/root
  fi
fi
