#!/bin/ksh

# do_sqlall.sh: loop over all nodes with a sql-file...
#
#   $1: the sql file to run (file+extention), 
#       will be cpied to /tmp, and hopefully removed
#
# todo: HARDcoded nodenames : make a list.
# todo: primitive, need better solution.. preferably with an EOF or HERE-doc
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
for node in roach1 roach2 roach3 roach4 roach5 roach6 roach7
do

  echo doing node $node ' ... ' 
  docker cp $1 $node:/tmp/doit.sql
  docker exec -it $node cockroach sql --host $node:26257 --insecure -e '\i /tmp/doit.sql ' 
  docker exec -it $node rm /tmp/doit.sql

done


echo .
echo do_sqlall.sh: done, please check...
echo . 
