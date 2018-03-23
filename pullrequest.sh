#!/bin/bash

TIMEOUT=3

if [ -z "$1" ]; then
    echo "Usage: $0 [target_branch]"
    exit 0
fi

GITROOT=$(git rev-parse --show-toplevel)
if [ -z "$GITROOT" ] || [ ! -f "$GITROOT/.git/HEAD" ]; then
    echo "$0 Must be called inside a git repo"
    exit -1
fi

GITHEAD=$(grep ^ref $GITROOT/.git/HEAD | tail -1 | grep -oE "[^/]+$")
if [ -z "$GITHEAD" ]; then
    echo "Unable to deduce git head"
    exit -2
fi

git push origin $GITHEAD
if [ $? -ne 0 ]; then
   GITERROR=$?
   echo "Unable to push - error code $GITERROR"
   exit $GITERROR
fi

for i in "x-www-browser" "google-chrome" "firefox" "safari"
do
    if [ -x "$(which $i)" ]; then
        export BROWSER=$i
        break
    fi
done

GITURL=$(grep url $GITROOT/.git/config | tail -1 | grep -oE "[^@]+$" | cut -d: -f1)
if [ -z "$GITURL" ]; then
    echo "Unable to deduce git url"
    exit -3
fi

if [ -z "$GITUSER" ]; then
    GITUSER=$(whoami)
fi

REMOTE=$(git remote -v | grep push | grep "upstream" | grep -oE "[^:]+$" | cut -d. -f1)

sleep $TIMEOUT
$BROWSER https://$GITURL/$REMOTE/compare/$1...$GITUSER:$GITHEAD?expand=1 

