#!/bin/bash

# chk_crsql.sh: loop over all nodes to see if psql/cr-sql is working
#
# todo: HARDcoded nodenames: make a list.
#
# typical usage: chck if cr is running on all nodes, 
#

#  verify first, show command

echo .
echo checking cr-connectivity nodes 1-7 
echo .

# do it once, quick..., 
# note: better/ideally all container-nodes listen on same port..
#       and we map the conterner-ports to a set of host-ports 

for node in roach1 roach2 roach3 roach4 roach5 roach6 roach7 
do

  echo doing node $node  
  docker exec -it $node cockroach --host=$node:26257 sql --insecure -e "select version();"
  sleep 2

done

for pgport in 26257 26258 26259 26260 26261 26262 26263
do

  echo -n psql checking local port $pgport : 
  psql -h localhost -p $pgport -U root -d defaultdb -X -c "\q"
  if [ $? -eq 0 ] 
  then 
    echo ok
  else
    echo Not Available
  fi

  sleep  2

done 

echo .
echo done checking nodes and ports for pg-connectivity
echo . 
