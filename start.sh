#!/bin/sh

CONF=/etc/easy2ban/easy2ban.conf
RULES=`ls /etc/easy2ban/rules-enabled/*.conf 2>/dev/null`

sudo easy2ban-ipban &

for rule in $RULES; do
	easy2ban-rule -c $CONF -c $rule &
done

