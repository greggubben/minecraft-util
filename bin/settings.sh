#
# Overall Minecraft server settings
#
# Should be sources at the begining of all Minecraft scripts
# . /proj/minecraft/bin/settings.sh
#

MCROOT='/proj/minecraft'
MCROOTSERVERS=$MCROOT/servers
MCROOTBACKUP=$MCROOT/backup
MCROOTWEB=$MCROOT/web

export MCROOT MCROOTSERVERS MCROOTBACKUP MCROOTWEB

# Overviewer settings
MCOVERVIEWERDIR=$MCROOT/overviewer
MCWEBASSETS=$MCROOT/web_assets

export MCOVERVIEWERDIR MCWEBASSETS
