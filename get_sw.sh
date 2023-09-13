#!/bin/sh

get_sw.sh: form nodeX to some other container/s..

export fromnode=nodeX
export tonode=roach1
export swdir=./swdir

mkdir $swdir

export swlist="vi ps find iostat"

for sw in $swlist
do
  docker cp  fromnode:/usr/bin/vi  $swdir
done

# check
ls -l $swdir



