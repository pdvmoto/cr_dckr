#!/bin/sh

# add_cr_clu.sh: add cockroach nodes to cluster, try 9 nodes.
#
# todo:
#  - check.. doublechck
#  - errors? check node+port for Every setting and mapping..
#  - how does cluster grow? join-addresses seem fixed at 3 nodes?
#  - volumes are Faster ?? verify!
#  - investigate K8S.. better ?
#  - add tools to containers ? : .psqlrc, .bashrc, .env?
#
# notes: 
# - seven, to have a nice weird number
# - inside containers, try keeping identical config, identical ports. 
#   hence on container-level everyone is on ports 8080, 26257 etc
#   map the ports mapped to localhost, where numbers are 81, 82, 83 etc.
# - 
#

# network, cr wants bridged
docker network create -d bridge roachnet

# volumes, verify cr-stmt that volumes are faster..
docker volume create vol_roach8
docker volume create vol_roach9

docker volume list | grep roach

echo .
echo .
read -p "Additional Volumes created ? ... " abc

# note the mapping: -p localhost-port:container-port
# ports for 8080 mapped to host 8081-7
# ports for advertise+listen: always 26357 (all)
# ports sql-addr: numbered from 26357..26363, and mapped to host
# join addresses: just 3, and all to same, advertized/listen port
# initial cluster on 3 nodes.. 

# first container, 

docker run -d --name=roach8 --hostname=roach8 --net=roachnet \
  -p 26264:26257 -p 8088:8080               \
  -v "vol_roach8:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start \
      --advertise-addr=roach8:26357   \
           --http-addr=roach8:8080    \
         --listen-addr=roach8:26357   \
            --sql-addr=roach8:26257   \
      --insecure   --join=roach6:26357,roach7:26357

# seems like a good practice from other clusters
sleep 3

echo .
echo .
read -p "node 8 joined ? " abc

docker run -d --name=roach9 --hostname=roach9 --net=roachnet \
  -p 26265:26257 -p 8089:8080               \
  -v "vol_roach9:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start \
           --http-addr=roach9:8080    \
            --sql-addr=roach9:26257   \
      --advertise-addr=roach9:26357   \
         --listen-addr=roach9:26357   \
      --insecure     --join=roach7:26357,roach6:26357

sleep 3 

echo .
echo .
# read -p "Two more nodes created ? " abc


#
# nodes are up+running..?
#

docker ps | grep roach


echo .
echo .

# verify via node roach9, ..
docker exec -it roach9 grep 'node starting' /cockroach/cockroach-data/logs/cockroach.log -A 11

# and check SQL...(sneakily use node roach2..)
docker exec -it roach9 ./cockroach sql --host=roach9:26257 --insecure -e "select node_id, address from crdb_internal.gossip_nodes;"

echo . 
echo $0 done, cluster running? check it... 
echo .

