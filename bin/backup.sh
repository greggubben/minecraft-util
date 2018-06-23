#
# Backup Gregg's files
#

BACKUPHOST="minecraft@ubben-nas.local"
BACKUPDIRROOT="/volume1/Backup/minecraft/gregg-desktop"

do_backup() {

  # Check for Source Directory
  if [ "$1" == "" ]
  then
    echo "Missing source"
    return
  else
    SOURCEDIR="$1"
  fi

  # Check for Destination Directory
  if [ "$2" == "" ]
  then
    echo "Missing destination"
    return
  else
    DESTDIR="$2"
  fi

  # Check for additional args
  ADDARGS=""
  if [ "$3" != "" ]
  then
    ADDARGS="$3"
  fi

  # Create a backup of the Backup directory on the ubben-nas
  echo rsync -av $ADDARGS $SOURCEDIR $BACKUPHOST:$BACKUPDIRROOT/$DESTDIR
  rsync -av $ADDARGS $SOURCEDIR $BACKUPHOST:$BACKUPDIRROOT/$DESTDIR
}

# Backup key directories
do_backup "/proj/minecraft" "" "--exclude=backup --exclude=world --exclude=www" 

