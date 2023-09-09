#!/bin/sh

# mk_cr_clu.sh: create cockroach cluster, try 7 nodes.
#
# todo:
#  - check.. doublechck
#  - errors? check node+port for Every setting and mapping..
#  - how does cluster grow? join-addresses seem fixed at 3 nodes?
#  - volumes are Faster ?? verify!
#  - investigate K8S.. better ?
#  - add tools to containers ? : .psqlrc, .bashrc, .env?
#

# network, cr wants bridged
docker network create -d bridge roachnet

# volumes, verify cr-stmt that volumes are faster..
docker volume create vol_roach1
docker volume create vol_roach2
docker volume create vol_roach3
docker volume create vol_roach4
docker volume create vol_roach5
docker volume create vol_roach6
docker volume create vol_roach7

docker volume list | grep roach

echo .
echo .
read -p "volumes created ? " abc

# note the mapping: -p localhost-port:container-port
# ports for 8080 mapped to host 8081:  umbered 1-7
# ports for advertise+listen: always 26357 (all)
# ports sql-addr: numbered from 26357..26363, and mapped to host
# join addresses: just 3, and all to same, advertized/listen port
# initial cluster on 3 nodes.. 

# first container, 

docker run -d --name=roach1 --hostname=roach1 --net=roachnet \
  -p 26257:26257 -p 8081:8081               \
  -v "vol_roach1:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start \
      --advertise-addr=roach1:26357   \
           --http-addr=roach1:8081    \
         --listen-addr=roach1:26357   \
            --sql-addr=roach1:26257   \
      --insecure   --join=roach1:26357,roach2:26357,roach3:26357

# seems like a good practice from other clusters
sleep 3

echo .
echo .
read -p "first node created ? " abc

# another 6 nodes to add...
# not using for-loop yet bcse of port-mappings

docker run -d --name=roach2 --hostname=roach2 --net=roachnet \
  -p 26258:26258 -p 8082:8082               \
  -v "vol_roach2:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start \
      --advertise-addr=roach2:26357   \
           --http-addr=roach2:8082    \
         --listen-addr=roach2:26357   \
            --sql-addr=roach2:26258   \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3 

echo .
echo .
read -p "second node created ? " abc

docker run -d --name=roach3 --hostname=roach3 --net=roachnet \
  -p 26259:26259 -p 8083:8083               \
  -v "vol_roach3:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start \
      --advertise-addr=roach3:26357   \
           --http-addr=roach3:8083    \
         --listen-addr=roach3:26357   \
            --sql-addr=roach3:26259   \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3

echo .
echo .
read -p "third node created ? " abc


# nr 4, the first one not in the join-list.. ?

docker run -d --name=roach4 --hostname=roach4 --net=roachnet \
  -p 26260:26260 -p 8084:8084               \
  -v "vol_roach4:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start       \
      --advertise-addr=roach4:26357         \
           --http-addr=roach4:8084          \
         --listen-addr=roach4:26357         \
            --sql-addr=roach4:26260         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3

echo .
echo .
read -p "fourth node created ? " abc

# nr 5, the second one not in the join-list.. ?

docker run -d --name=roach5 --hostname=roach5 --net=roachnet \
  -p 26261:26261 -p 8085:8085               \
  -v "vol_roach5:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start       \
           --http-addr=roach5:8085          \
      --advertise-addr=roach5:26357         \
         --listen-addr=roach5:26357         \
            --sql-addr=roach5:26261         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3

echo .
echo .
read -p "fifth node created ? " abc

# nr 6, the third one not in the join-list.. ?

docker run -d --name=roach6 --hostname=roach6 --net=roachnet \
  -p 26262:26262 -p 8086:8086               \
  -v "vol_roach6:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start       \
           --http-addr=roach6:8086          \
      --advertise-addr=roach6:26357         \
         --listen-addr=roach6:26357         \
            --sql-addr=roach6:26262         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3

echo .
echo .
read -p "sixth node created ? " abc

# nr 7, the fourth not that is not in the join-list.. ?

docker run -d --name=roach7 --hostname=roach7 --net=roachnet \
  -p 26263:26263 -p 8087:8087               \
  -v "vol_roach7:/cockroach/cockroach-data" \
  cockroachdb/cockroach:v23.1.9 start       \
           --http-addr=roach7:8087          \
      --advertise-addr=roach7:26357         \
         --listen-addr=roach7:26357         \
            --sql-addr=roach7:26263         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3

echo .
echo .
read -p "seventh, and last, node created ? " abc


#
# nodes are up+running..?
#

docker ps | grep roach

#init cluster

docker exec -it roach1 ./cockroach --host=roach1:26357 init --insecure

echo .
echo .
read -p "init cluster done ? " abc

# verify via node roach1, ..
docker exec -it roach1 grep 'node starting' /cockroach/cockroach-data/logs/cockroach.log -A 11

# and check SQL...(sneakily use node roach2..)
docker exec -it roach1 ./cockroach sql --host=roach2:26258 --insecure

echo . 
echo $0 done, cluster running? check it... 
echo .

