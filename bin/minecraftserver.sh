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
# MCSERVERWORLD   - the directory of the minecraft server world
# MCSERVEROFFLINE - the directory of the minecraft server world in offline mode
# WORLD='world'
# OFFLINE_WORLD='world-offline'

# Common Settings
SERVICE=$MCSERVERJAR
OPTIONS='nogui'
USERNAME='minecraft'
MCPATH=$MCSERVERROOT
BACKUPPATH=$MCSERVERBACKUP
CPU_COUNT=2
INVOCATION="java -Xmx1024M -Xms512M -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts -jar $SERVICE"


ME=`whoami`
as_user() {
  if [ $ME == $USERNAME ] ; then
    bash -c "$1"
  else
    su - $USERNAME -c "$1"
  fi
}

mc_start() {
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
  then
    echo "$SERVICE is already running!"
  else
    echo "Starting $SERVICE..."
    cd $MCPATH
    as_user "cd $MCPATH && screen -dmS $SCREEN_NAME $INVOCATION $OPTIONS"
    sleep 7
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
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
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
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
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
  then
    echo "$SERVICE is running... re-enabling saves"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"save-on\"\015'"
    as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"say SERVER BACKUP ENDED. Server going read-write...\"\015'"
  else
    echo "$SERVICE is not running. Not resuming saves."
  fi
}

mc_stop() {
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
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
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
  then
    echo "Error! $SERVICE could not be stopped."
  else
    echo "$SERVICE is stopped."
  fi
}

mc_update() {
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
  then
    echo "$SERVICE is running! Will not start update."
  else
      if [ "$1" ]
      then
        MC_SERVER_FILE="$1"
        #MC_SERVER_URL=http://www.minecraft.net/download/minecraft_server.jar?v=`date | sed "s/[^a-zA-Z0-9]/_/g"`
        #as_user "cd $MCPATH && wget -q -O $MCPATH/minecraft_server.jar.update $MC_SERVER_URL"
        if [ -f $MC_SERVER_FILE ]
        then
          if `diff $MCPATH/$SERVICE $MC_SERVER_FILE >/dev/null`
          then 
            echo "You are already running the latest version of $SERVICE."
          else
            as_user "mv $MCPATH/$SERVICE $MCPATH/$SERVICE.old"
            as_user "cp $MC_SERVER_FILE $MCPATH/$SERVICE"
            echo "Minecraft successfully updated."
          fi
        else
          echo "Minecraft server file $MC_SERVER_FILE does not exist."
        fi
     else
       echo "Missing Minecraft server file argument."
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
   echo "Backing up minecraft world..."
   if [ -d $BACKUPPATH/$WORLD_`date "+%Y.%m.%d"` ]
   then
     for i in 1 2 3 4 5 6
     do
       if [ -d $BACKUPPATH/$WORLD_`date "+%Y.%m.%d"`-$i ]
       then
         continue
       else
         as_user "cd $MCPATH && cp -r --preserve=all $WORLD $BACKUPPATH/$WORLD_`date "+%Y.%m.%d"`-$i"
         break
       fi
     done
   else
     as_user "cd $MCPATH && cp -r --preserve=all $WORLD $BACKUPPATH/$WORLD_`date "+%Y.%m.%d"`"
     echo "Backed up world"
   fi
   echo "Backing up $SERVICE"
   if [ -f "$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d"`.jar" ]
   then
     for i in 1 2 3 4 5 6
     do
       if [ -f "$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d"`-$i.jar" ]
       then
         continue
       else
         as_user "cd $MCPATH && cp $SERVICE \"$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d"`-$i.jar\""
         break
       fi
     done
   else
     as_user "cd $MCPATH && cp $SERVICE \"$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d"`.jar\""
   fi
   echo "Backup complete"
}

mc_command() {
  if [ "$1" ]
  then
    command="$1";
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
    then
      echo "$SERVICE is running... executing command"
      as_user "screen -p 0 -S $SCREEN_NAME -X eval 'stuff \"$command\"\015'"
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
  stop)
    mc_stop
    ;;
  restart)
    mc_stop
    mc_start
    ;;
  update)
    mc_stop
    mc_backup
    mc_update "$2"
    mc_start
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
    mc_saveoff
    mc_backup
    mc_saveon
    ;;
  status)
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
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
  echo "Usage: /etc/init.d/minecraft {start|stop|update|backup|status|restart|display|sync|command \"server command\"}"
  exit 1
  ;;
esac

exit 0
