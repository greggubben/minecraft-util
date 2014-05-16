#
# This script is executed after the minecraft map settings have been
# prepared.
#
# It will Generate all the Points Of Interest (POI) for an already
# generated map.

#
# The following values must be set prior to running this script:
#
# MCSERVEROFFLINE - the directory of the minecraft server world in offline mode
# MCSERVERWEB     - the directory of the minecraft web directory
# MCWEBASSETS     - the directory of the common images needed for Generating POI

# Define the Map Generating program
MAPBUILDER=$MCOVERVIEWERDIR/overviewer.py

# Define the Master Settings for Generating the Map
SETTINGS=$MCROOT/bin/buildmapsettings.py

# Define the directory that contains the World
OV_WORLD=$MCSERVEROFFLINE

# Define the directory that contains the World
OV_OUTPUTBASEDIR=$MCSERVERWEB

# Define the directory that contains the Web Assets for building the Web Pages
OV_WEBASSETS=$MCWEBASSETS

export OV_WORLD OV_OUTPUTBASEDIR OV_WEBASSETS

#
# Build minecraft map
#
if [ ! -d $OV_OUTPUTBASEDIR ]
then
    mkdir $OV_OUTPUTBASEDIR
fi
$MAPBUILDER --config=$SETTINGS $* --genpoi

