#
# Notify Slack of changes to the server
#

#
# The following file defines SLACK_URL and SLACK_SECRET based on
# what slack provided when the web hook was created
. /proj/minecraft/bin/slack.conf

SLACK_USERNAME="Nick's Minecraft Server"
SLACK_CHANNEL="#general"
SLACK_POST="$SLACK_URL/$SLACK_SECRET"

if [ "$1" ]
then
    message="$1"
    icon=""
    if [ "$2" ]
    then
        icon=", \"icon_emoji\": \":$2:\" "
    fi
    curl -X POST --data-urlencode 'payload={"channel": "'"$SLACK_CHANNEL"'", "username": "'"$SLACK_USERNAME"'", "text": "'"$message"'" '"$icon"'}' $SLACK_POST

else
    echo "Usage: $0 message [icon]"
    exit 1
fi
exit 0
