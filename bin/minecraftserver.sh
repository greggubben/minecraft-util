#
# This script is executed after the minecraft server settings have been
# prepared.
#
# 

#
# The following values must be set prior to running this script:
#
# MCSERVERJAR     - the jar file of the minecraft server
# MCSERVERROOT    - the root directory of the minecraft server
# MCSERVERBACKUP  - the directory to place the backups of the minecraft server
# SCREEN_NAME     - the name of the minecraft server
# MCUSERNAME      - the owner of the minecraft server process and files
# MCSERVERWORLD   - the directory of the minecraft server world
# MCSERVEROFFLINE - the directory of the minecraft server world in offline mode
# WORLD='world'
# OFFLINE_WORLD='world-offline'
# MCSERVERWEB     - the directory of the minecraft web directory
# MCWEBASSETS     - the directory of the common images needed for Generating POI


# Common Minecraft Server Settings
# Name of the Service
SERVICE=$MCSERVERJAR
# User to run the Service as
USERNAME=$MCUSERNAME
# Path to the Minecraft Server
MCPATH=$MCSERVERROOT
# Location to place backups
BACKUPPATH=$MCSERVERBACKUP
# Invocation Settings
OPTIONS='nogui'
CPU_COUNT=2
MAXHEAP=1024
MINHEAP=1024
HISTORY=1024
INVOCATION="java -Xmx${MAXHEAP}M -Xms${MINHEAP}M -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts -jar $SERVICE $OPTIONS"

# Common Map Builder Settings
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
# Export values need by the settings file
export OV_WORLD OV_OUTPUTBASEDIR OV_WEBASSETS MCTEXTUREPATH

# Common Log Analyzer Settings
LOGANALYZER="$MCLOGALYZERDIR/mclogalyzer/mclogalyzer.py"

ME=`whoami`
as_user() {
  if [ $ME == $USERNAME ] ; then
    bash -c "$1"
  else
    su - $USERNAME -p -c "$1"
  fi
}

mc_start() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is already running!"
  else
    echo "Starting $SERVICE..."
    cd $MCPATH
    as_user "cd $MCPATH && screen -dmS $SCREEN_NAME $INVOCATION"
    sleep 7
    if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is now running."
    else
      echo "Error! Could not start $SERVICE!"
    fi
  fi
}

mc_hide() {
    screen -d -S $SCREEN_NAME
}

mc_display() {
    screen -x -S $SCREEN_NAME
}

mc_saveoff() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running... suspending saves"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"say SERVER BACKUP STARTING. Server going readonly...\"\015'"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"save-off\"\015'"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"save-all\"\015'"
    sync
    sleep 10
  else
    echo "$SERVICE is not running. Not suspending saves."
  fi
}

mc_saveon() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running... re-enabling saves"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"save-on\"\015'"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"say SERVER BACKUP ENDED. Server going read-write...\"\015'"
  else
    echo "$SERVICE is not running. Not resuming saves."
  fi
}

mc_stop() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "Stopping $SERVICE"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map...\"\015'"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"save-all\"\015'"
    sleep 10
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"stop\"\015'"
    sleep 7
  else
    echo "$SERVICE was not running."
  fi
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "Error! $SERVICE could not be stopped."
  else
    echo "$SERVICE is stopped."
  fi
}

mc_check_update() {
   as_user "cd $MCPATH && wget -q -O $MCPATH/versions https://launchermeta.mojang.com/mc/game/version_manifest.json"
   snap=`cat $MCPATH/versions | sed 's/\n//g' | sed 's/}/\n/g' | grep latest | sed 's/{/\n/g' | sed 's/,/\n/g' | grep snapshot`
   snapVersion=`echo $snap | awk -F'\"' '{print $4}'`
   re=`cat $MCPATH/versions | sed 's/\n//g' | sed 's/}/\n/g' | grep latest | sed 's/{/\n/g' | sed 's/,/\n/g' | grep release`
   reVersion=`echo $re | awk -F'\"' '{print $4}'`
   echo "Latest Versions"
   echo "Release:  $reVersion"
   echo "Snapshot: $snapVersion"
   as_user "rm $MCPATH/versions"
}


mc_update() {
   if pgrep -u $USERNAME -f $SERVICE > /dev/null
   then
     echo "$SERVICE is running! Will not start update."
   else
     #as_user "cd $MCPATH && wget -q -O $MCPATH/versions http://s3.amazonaws.com/Minecraft.Download/versions/versions.json"
     as_user "cd $MCPATH && wget -q -O $MCPATH/versions https://launchermeta.mojang.com/mc/game/version_manifest.json"
        #snap=`awk -v linenum=3 'NR == linenum {print; exit}' "$MCPATH/versions"`
        snap=`cat $MCPATH/versions | sed 's/\n//g' | sed 's/}/\n/g' | grep latest | sed 's/{/\n/g' | sed 's/,/\n/g' | grep snapshot`
        snapVersion=`echo $snap | awk -F'\"' '{print $4}'`
        #re=`awk -v linenum=4 'NR == linenum {print; exit}' "$MCPATH/versions"`
        re=`cat $MCPATH/versions | sed 's/\n//g' | sed 's/}/\n/g' | grep latest | sed 's/{/\n/g' | sed 's/,/\n/g' | grep release`
        reVersion=`echo $re | awk -F'\"' '{print $4}'`
        echo "Latest Versions"
        echo "Release: $reVersion"
        echo "Snapshot: $snapVersion"
        as_user "rm $MCPATH/versions"
        if [ "$1" == "snapshot" ]; then
          echo "Getting latest snapshot $snapVersion"
          MC_SERVER_URL=http://s3.amazonaws.com/Minecraft.Download/versions/$snapVersion/minecraft_server.$snapVersion.jar
        else
          echo "Getting latest release $reVersion"
          MC_SERVER_URL=http://s3.amazonaws.com/Minecraft.Download/versions/$reVersion/minecraft_server.$reVersion.jar
        fi
     as_user "cd $MCPATH && wget -q -O $MCPATH/minecraft_server.jar.update $MC_SERVER_URL"
     if [ -f $MCPATH/minecraft_server.jar.update ]
     then
       if `diff $MCPATH/$SERVICE $MCPATH/minecraft_server.jar.update >/dev/null`
       then
         as_user "rm $MCPATH/minecraft_server.jar.update"
         echo "You are already running the latest version of $SERVICE."
       else
         as_user "mv $MCPATH/minecraft_server.jar.update $MCPATH/$SERVICE"
         echo "Minecraft successfully updated."
       fi
     else
       echo "Minecraft update could not be downloaded."
     fi
   fi
}

mc_sync_offline() {
  if [[ -e $MCPATH/synclock ]]; then
    echo "Previous sync hasn't completed or has failed"
  else
    touch $MCPATH/synclock

    echo "Sync in progress..."

    mkdir -p $MCSERVEROFFLINE
    rsync -a $MCSERVERWORLD/ $MCSERVEROFFLINE/
    WORLD_SIZE=$(du -s $MCSERVERWORLD/ | sed s/[[:space:]].*//g)
    OFFLINE_SIZE=$(du -s $MCSERVEROFFLINE/ | sed s/[[:space:]].*//g)
    echo "WORLD  : $WORLD_SIZE KB"
    echo "OFFLINE: $OFFLINE_SIZE KB"

    rm $MCPATH/synclock
    echo "Sync is complete"
  fi
}

mc_backup() {
    mc_saveoff

    NOW=`date "+%Y-%m-%d_%Hh%M"`
    BACKUP_FILE="$BACKUPPATH/${WORLD}_${NOW}.tar"
    echo "Backing up minecraft world..."
    #as_user "cd $MCPATH && cp -r $WORLD $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"`"
    as_user "tar -C \"$MCPATH\" -cf \"$BACKUP_FILE\" $WORLD"

    echo "Backing up $SERVICE"
    as_user "tar -C \"$MCPATH\" -rf \"$BACKUP_FILE\" $SERVICE"
    #as_user "cp \"$MCPATH/$SERVICE\" \"$BACKUPPATH/minecraft_server_${NOW}.jar\""

    mc_saveon

    echo "Compressing backup..."
    as_user "gzip -f \"$BACKUP_FILE\""
    echo "Backup complete"
}

mc_buildmap() {
    #
    # Build minecraft map
    #
    if [ ! -d $OV_OUTPUTBASEDIR ]
    then
        mkdir $OV_OUTPUTBASEDIR
    fi
    as_user "$MAPBUILDER --config=$SETTINGS $*"
}

mc_genpoi() {
    #
    # Generate Points of Interest (POI) for minecraft map
    #
    if [ ! -d $OV_OUTPUTBASEDIR ]
    then
        mkdir $OV_OUTPUTBASEDIR
    fi
    as_user "rm -rf $MCOVERVIEWERTMP/*"
    as_user "$MAPBUILDER --config=$SETTINGS $* --genpoi"
}

mc_loganalyzer() {
    #
    # Generate Points of Interest (POI) for minecraft map
    #
    if [ ! -d $OV_OUTPUTBASEDIR ]
    then
        mkdir $OV_OUTPUTBASEDIR
    fi
    as_user "$LOGANALYZER $MCSERVERLOGS $MCSERVERWEB/stats.html"
}

mc_command() {
  if [ "$1" ]
  then
    command="$1";
    if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      pre_log_len=`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`
      echo "$SERVICE is running... executing command"
      as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"$command\"\015'"
      sleep .1 # assumes that the command will run and print to the log file in less than .1 seconds
      # print output
      tail -n $[`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`-$pre_log_len] "$MCPATH/logs/latest.log"
    else
      echo "$SERVICE was not running."
    fi
    else
      echo "Must specify server command"
  fi
}

#Start-Stop here
case "$1" in
  start)
    mc_start
    ;;
  display)
    mc_display
    ;;
  hide)
    mc_hide
    ;;
  stop)
    mc_stop
    ;;
  restart)
    mc_stop
    mc_start
    ;;
  update)
    if [[ "check" == $2 ]]; then
      mc_check_update
    else
      mc_stop
      mc_backup
      mc_update "$2"
      mc_start
    fi
    ;;
  sync)
    if [[ "purge" == $2 ]]; then
        echo "Purging offline folder..."
	rm -rf $MCSERVEROFFLINE/
	echo "Purge Complete"
    fi
    mc_saveoff
    mc_sync_offline
    mc_saveon
    ;;
  backup)
    mc_backup
    ;;
  buildmap)
    echo "Started on: `date`"
    echo
    mc_saveoff
    mc_sync_offline
    mc_saveon
    shift
    echo
    echo "Building the Map"
    echo
    mc_buildmap "$*"
    echo
    echo "Generating the Points of Interest"
    echo
    mc_genpoi "$*"
    echo
    echo "Analyzing the Logs"
    echo
    mc_loganalyzer
    echo
    echo "Completed on: `date`"
    ;;
  genpoi)
    shift
    mc_genpoi "$*"
    ;;
  loganalyzer)
    mc_loganalyzer
    ;;
  status)
    if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is running."
    else
      echo "$SERVICE is not running."
    fi
    ;;
  command)
    mc_command "$2"
    ;;

  *)
  echo "Usage: $0 {start|stop|backup|status|restart|display|hide|loganalyzer}"
  echo "       $0 command \"server command\""
  echo "       $0 sync [purge]"
  echo "       $0 update [snapshot|check]"
  echo "       $0 buildmap [options]"
  echo "       $0 genpoi [options]"
  exit 1
  ;;
esac

exit 0
