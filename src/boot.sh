#!/bin/bash

# Mystic BBS docker boot script

# cleanup procedure
cleanup() {
    echo "Container stopped, performing cleanup..." >> /mystic/logs/mis.log
    
    # stop server
    /mystic/stop.sh
    
    #exit our script (pid 1) thus closing docker correctly
    exit 0
}

# trap SIGTERM
trap 'cleanup' SIGTERM

if [ "$1" = 'mystic' ]; then

    # run cron for fido polling
    
    # run server
    /mystic/start.sh &
    

    touch /mystic/logs/node1.log
    ln -sf /proc/1/fd/1 /mystic/logs/node1.log

    # because we can not run the server mode
    while true
      do sleep 1
    done    
    
    # run as server on background, takes waaay to much CPU!
    # this is this correct solution but in this case inefficient
    # /mystic/mis server &    
    
# else
#     exec "$@" &
fi
