#!/bin/sh

get_sw.sh: form nodeC to some other container/s..

export fromnode=nodeC
export tonode=roach1
export swdir=swdir
export targetdir=/usr/local/sbin

mkdir $swdir

export swlist="vi find iostat lscpu lsmem unzip watch which zip "
export otherlist="ps sadc sadf sar top "
export nodelist="roach1 roach2 roach3 roach4 roach4  roach5  roach6  roach7  roach8  roach9  "


for sw in $swlist
do
  echo fetching $sw
  docker cp  $fromnode:/usr/bin/$sw  $swdir
done

# check
ls -l $swdir


for node in $nodelist
do

  echo copying sw to $node

  for sw in $swlist
  do
    echo copying $swdir/$sw
    docker cp $swdir/$sw $node:$targetdir/

  done

  echo $node done moving to next...

done


echo --- sw copies done --- 
