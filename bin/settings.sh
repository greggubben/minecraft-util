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
MCROOTBIN=$MCROOT/bin
MCUSERNAME='minecraft'

export MCROOT MCROOTSERVERS MCROOTBACKUP MCROOTWEB MCROOTBIN MCUSERNAME

# Specific Files
MCCRONTABFILE=$MCROOT/crontab/crontab

export MCCRONTABFILE

# Overviewer settings
MCOVERVIEWERDIR=$MCROOT/overviewer
MCWEBASSETS=$MCROOT/web_assets
MCOVERVIEWERTMP=/tmp/overviewer

export MCOVERVIEWERDIR MCWEBASSETS MCOVERVIEWERTMP

# Textures settings
MCTEXTUREPATH=$MCROOT/client

export MCTEXTUREPATH

# MCLogalyzer settings
MCLOGALYZERDIR=$MCROOT/mclogalyzer

export MCLOGALYZERDIR

# NAS Backup
NASBACKUPHOST="minecraft@ubben-nas.local"
NASBACKUPROOT="/volume1/Backup/minecraft/gregg-desktop"

export NASBACKUPHOST NASBACKUPROOT

# Update PATH to include minecraft/bin
PATH=$PATH:$MCROOTBIN
export PATH
