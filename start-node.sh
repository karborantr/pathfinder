#!/bin/bash
set -e

if [ "$IDLE" == "1" ]; then
    echo "Detected \$IDLE=1 env variable"
    echo "Starknet Pathfinder will now idle"
    echo "To restart normally, remove the env variable and the container will restart"
    tail -f /dev/null
else
  tini -s -- /usr/local/bin/pathfinder $*
fi
