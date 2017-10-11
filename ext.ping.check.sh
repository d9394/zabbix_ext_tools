#!/bin/bash
if [ $# != 2 ] ; then
  echo USIGE: $0 IP FUNC
  echo FUNC=1 : check IP alive=1 ro dead=0
  echo FUNC=2 : check Ping IP return average delay time
else
  if [ "$2" == "1" ]; then
    ping -c 1 -w 1 $1 &>/dev/null && result1=1 || result1=0
    echo $result1
  fi
  if [ "$2" == "2" ]; then
    TIME=`ping $1 -c 2 | sed -n 's/.* = .*\/\(.*\)\/.*\/.*/\1/p'`
    echo $TIME
  fi
fi
