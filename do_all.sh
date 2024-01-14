#!/bin/ksh

# do_all.sh: loop over all nodes with a command...
#
# todo: HARDcoded nodenames TWICE: make a list.
#
# typical usage: measure disk-usage, or check tablets..
# ./do_all.sh du -sh --inodes /root/var/data/yb-data/
# ./do_all.sh yb-admin  -master_addresses node1:7100 list_tablets ysql.yugabyte t_1st 0 
#

#  verify first, show command

echo .
echo do_all: \[  $* \] ...  cockroach docker cluster 
echo .

# do it once, quick...
# roach6 roach7 roach8 roach9
for node in roach1 roach2 roach3 roach4 roach5 
do

  echo -n doing node $node ' : ' 
  docker exec -it $node $*

done


echo .
echo do_all.sh: 10 sec to Cntr-C .. or .. continue doing it slower forever...
echo . 

sleep 10

# now loop slowly over nodes
while true 
do

  echo .
  echo ----- $0 : \[  $* \] ... cockroach on docker
  echo .

  for node in roach1 roach2 roach3 roach4 roach5 # roach6 roach7 roach8 roach9
  do

    # echo .
    echo -n node $node ' : ' 
    docker exec -it $node $*

    sleep 5 

  done

  echo .
  echo ----- $0 : cockroach loop over nodes done, next.. 
  sleep 15

done 

# ----------------- end do_all_clu.sh -------------

echo .
echo notes: code should never get this far.. but keep as notes
echo .

sleep 10

while true 
do

  echo node1:
  docker exec node1  ps -ef  | grep database_host | cut -d= -f2  
  docker exec -it node1 yugabyted status | grep atus; sleep 3 ; echo .

  echo node2:
  docker exec node2  ps -ef  | grep database_host | cut -d= -f2  
  docker exec -it node2 yugabyted status | grep atus; sleep 3 ; echo .

  echo node3:
  docker exec node3  ps -ef  | grep database_host | cut -d= -f2  
  docker exec -it node3 yugabyted status | grep atus; sleep 3 ; echo .

  echo node4:
  docker exec node4  ps -ef  | grep database_host | cut -d= -f2  
  docker exec -it node4 yugabyted status | grep atus; sleep 6 ; echo .

  echo node5:
  docker exec node5  ps -ef  | grep database_host | cut -d= -f2  
  docker exec -it node4 yugabyted status | grep atus; sleep 6 ; echo .

  echo node6:
  docker exec node6  ps -ef  | grep database_host | cut -d= -f2  
  docker exec -it node4 yugabyted status | grep atus; sleep 6 ; echo .

done 

