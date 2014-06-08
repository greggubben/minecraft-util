#
# Overall Minecraft server settings
#
# Should be sources at the begining of all Minecraft scripts
# . /proj/minecraft/bin/settings.sh
#

# Overall Settings
MCROOT='/proj/minecraft'
MCROOTSERVERS=$MCROOT/servers
MCROOTBACKUP=$MCROOT/backup
MCROOTWEB=$MCROOT/web
MCUSERNAME='minecraft'

export MCROOT MCROOTSERVERS MCROOTBACKUP MCROOTWEB MCUSERNAME

# Overviewer settings
MCOVERVIEWERDIR=$MCROOT/overviewer
MCWEBASSETS=$MCROOT/web_assets

export MCOVERVIEWERDIR MCWEBASSETS

# Textures settings
MCTEXTUREPATH=$MCROOT/client

export MCTEXTUREPATH

# MCLogalyzer settings
MCLOGALYZERDIR=$MCROOT/mclogalyzer

