#!/bin/bash
# *** Configuration ***

# Your personal Slack URL key
HOOK_URL=https://hooks.slack.com/services/...
# The channel name to post
CHANNEL="#monitoring"
# Username for posting
USERNAME="fail2ban"
# Icon used for title
ICON=":cop:"
# Default color for the post
COLOR="#A9A9A9"
# Banned string to match in message (changes color to danger)
BANNED="Banned"
# Unbanned string to match in message (changes color to good)
UNBANNED="Unbanned"


# *** DO NOT EDIT BELOW THIS LINE, unless you know what you're doing :) ***

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    exit 1
fi

MESSAGE=$1
HOST=$(hostname -f)

if [ $# -eq 2 ]; then
    IP=$2
    IPHOST=$(dig +short -x $IP)
    if [ -z "$IPHOST" ]; then
        IPHOST="n/a"
    fi
    COUNTRY=$(curl -s ipinfo.io/${IP}/country)
    COUNTRY=$(echo "$COUNTRY" | tr -s  '[:upper:]'  '[:lower:]')
    COUNTRY=":flag-$COUNTRY:"
else
    COUNTRY=":flags:"
fi

MESSAGE="${MESSAGE/_country_/$COUNTRY}"

if [[ "$MESSAGE" =~ "$BANNED" ]]; then
    COLOR="danger"
elif [[ "$MESSAGE" =~ "$UNBANNED" ]]; then
    COLOR="good"
fi

PAYLOAD="{
    \"channel\": \"${CHANNEL}\",
    \"username\": \"${USERNAME}\",
    \"attachments\": [
        {
            \"color\": \"${COLOR}\",
            \"fallback\": \"${MESSAGE}\",
            \"fields\": [
                {
                    \"short\": true,
                    \"title\": \"IP Address\",
                    \"value\": \"${IP}\"
                },
                {
                    \"short\": true,
                    \"title\": \"Host name\",
                    \"value\": \"${IPHOST}\"
                }
            ],
            \"footer\": \"Fail2ban Alerts\",
            \"text\": \"${MESSAGE}\",
            \"title\": \"${ICON} Fail2ban on ${HOST}\",
            \"ts\": $(date +%s)
        }
    ]
}"

curl -s -X POST --data-urlencode "payload=$PAYLOAD" ${HOOK_URL}

exit $?
