#
# Overall Minecraft server settings
#
# Should be sources at the begining of all Minecraft scripts
# . /proj/minecraft/bin/settings.sh
#

. /proj/minecraft/bin/settings.sh

WORLD='world'
OFFLINE_WORLD='world-offline'
SCREEN_NAME='minecraft50'
MCSERVERROOT=$MCROOTSERVERS/$SCREEN_NAME
MCSERVERWORLD=$MCROOTSERVERS/$SCREEN_NAME/$WORLD
MCSERVEROFFLINE=$MCROOTSERVERS/$SCREEN_NAME/$OFFLINE_WORLD
MCSERVERBACKUP=$MCROOTBACKUP/$SCREEN_NAME
MCSERVERWEB=$MCROOTWEB/$SCREEN_NAME
MCSERVERJAR=$SCREEN_NAME.jar
