#
# Notify Slack of changes to the server
#

# Get the settins for Nick's Minecraft Server on 192.168.48.40
. /proj/minecraft/bin/settings40.sh

#
# The following file defines SLACK_URL and SLACK_SECRET based on
# what slack provided when the web hook was created
. /proj/minecraft/bin/slack.conf

SLACK_USERNAME="Nick's Minecraft Server"
SLACK_CHANNEL="#general"
SLACK_POST="$SLACK_URL/$SLACK_SECRET"

#
# Get the lastest copy of the log file
#
cp $MCSERVERLOGS/latest.log $MCSERVERLOGS/slack.diff
touch $MCSERVERLOGS/slack.last

#
# Process new log entries
#
diff $MCSERVERLOGS/slack.diff $MCSERVERLOGS/slack.last | grep "^<" | while read line
do
    #echo "$line"

    #
    # Check to see if someone joined the game
    #
    joined=`echo "$line" | grep "joined the game"`
    if [ "$joined" ]
    then
        goodpart=`echo "$line" | cut -d']' -f3 | cut -d' ' -f2-`
        echo "$goodpart"
        curl -X POST --data-urlencode 'payload={"channel": "'"$SLACK_CHANNEL"'", "username": "'"$SLACK_USERNAME"'", "text": "'"$goodpart"'", "icon_emoji": ":smiley:"}' $SLACK_POST
        echo
    fi

    #
    # Check to see if someone left the game
    #
    left=`echo "$line" | grep "left the game"`
    if [ "$left" ]
    then
        goodpart=`echo "$line" | cut -d']' -f3 | cut -d' ' -f2-`
        echo "$goodpart"
        curl -X POST --data-urlencode 'payload={"channel": "'"$SLACK_CHANNEL"'", "username": "'"$SLACK_USERNAME"'", "text": "'"$goodpart"'", "icon_emoji": ":cry:"}' $SLACK_POST
        echo
    fi

    #
    # Check to see if someone died
    #
    died=`echo "$line" | egrep "was squashed by|was pricked to death|walked into a cactus whilst|drowned|blew up|was blown up by|fell from a high place|hit the ground too hard|fell off a ladder|fell off some vines|fell out of the|fell into a patch of|was doomed to fall|was shot off|was blown from a high place|went up in flames|burned to death|was burnt to a crisp whilst|was slain by|was shot by|was fireballed by|was killed|got finished off by|tried to swim in lava|died|starved to death|suffocated in a wall|was pummeled by|was knocked into the void|withered away"`
    if [ "$died" ]
    then
        goodpart=`echo "$line" | cut -d']' -f3 | cut -d' ' -f2-`
        echo "$goodpart"
        usercomment=`echo "$goodpart" | grep "<"`
        if [ "$usercomment" ]
        then
            echo "User Comment"
        else
            echo "Real Death"
            curl -X POST --data-urlencode 'payload={"channel": "'"$SLACK_CHANNEL"'", "username": "'"$SLACK_USERNAME"'", "text": "'"$goodpart"'", "icon_emoji": ":skull:"}' $SLACK_POST
        fi
        echo
    fi


done

#
# keep the last log file for next compare
#
mv $MCSERVERLOGS/slack.diff $MCSERVERLOGS/slack.last
