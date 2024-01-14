#!/bin/ksh

# do_start.sh: loop over all nodes with a start command...
#
# todo: HARDcoded nodenames in list.
#
#

#  verify first, show command

echo .
echo $0 : starting cockroach nodes roach1 ... roach9 
echo .

# do it once, quick...
for node in roach1 roach2 roach3 roach4 roach5 roach6 roach7 roach8 roach9
do

  echo -n doing node $node ' : ' 
  docker start $node

done

echo .
echo .
echo Attempted to start all nodes.. checking..
echo .

docker ps

echo .
echo $0 done, please verify results..
echo . 
