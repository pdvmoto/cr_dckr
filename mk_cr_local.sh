#!/bin/sh

# mk_cr_local.sh: create cr cluster, on linux-containers, deploy CR manual
#
# todo:
#  - create 7 nodes., map ports, map volumes to external dirs
#  - copy tar and unpack
#  - start cockroach
#  - init.. 
#  - test...
#  - check.. doublechck
#  - errors? check node+port for Every setting and mapping..
#  - how does cluster grow? join-addresses seem fixed at 3 nodes?
#  - volumes are Faster ?? verify!
#  - investigate K8S.. better ?
#  - add tools to containers ? : .psqlrc, .bashrc, .env?
#  - try longer sleep to allow node-id = nodename
#
# notes: 
# - seven, to have a nice weird number
# - inside containers, try keeping identical config, identical ports. 
#   hence on container-level everyone is on ports 8080, 26257 etc
#   map the ports mapped to localhost, where numbers are 81, 82, 83 etc.
# - 
#

# set -v -x 

# Start with Network and Storage...  

# define which image: version, etc.. for linux, use yugabyte image..
# IMAGE=cockroachdb/cockroach:v23.1.9
# IMAGE=cockroachdb/cockroach
IMAGE=yugabytedb/yugabyte:2.20.1.3-b3


# get some file to log stmnts, start simple
LOGFILE=mk_nodes.log

echo .
echo logfile for creating cr nodes `date` > $LOGFILE
echo .

# nodes go here..


# roachnet, taken from webpage example 
docker network create -d bridge roachnet

# volumes, but consider externals 
docker volume create vol_roach1
docker volume create vol_roach2
docker volume create vol_roach3
docker volume create vol_roach4
docker volume create vol_roach5
docker volume create vol_roach6
docker volume create vol_roach7
docker volume create vol_roach8
docker volume create vol_roach9

docker volume list | grep roach

echo .
echo .
read -t 5 -p "Volumes created or available ? ... " abc

# note the mapping: -p localhost-port:container-port
# ports for 8080 mapped to host 8081-7
# ports for advertise+listen: always 26357 (all)
# ports sql-addr: numbered from 26357..26363, and mapped to host
# join addresses: just 3, and all to same, advertized/listen port
# initial cluster on 3 nodes.. 

# first container, 

# use loop to ensure identical nodes..
nodenrs="1 2 3 "

for nodenr in $nodenrs
do

  # define all relevant pieces (no spaces!)
  hname=roach${nodenr}
  httpport=800${nodenr}
  sqlport=2625${nodenr}
  
  echo .
  echo ---- ${hname} creating node ${hname}
  echo .

  # note : the advertise address is internal to roachnet, no map needed
  crecmd=` \
  echo docker run -d --network roachnet      \
    --hostname $hname --name $hname          \
    -p${httpport}:8080                       \
    -p${sqlport}:26257                       \
    -v /Users/pdvbv/yb_data/$hname:/root/var \
    $IMAGE                                   \
    /usr/bin/tail -f /dev/null`

  echo .
  echo ---- ${hname} about to execute
  echo ---- ${hname} $crecmd
  echo $crecmd >> $LOGFILE
  echo .
  $crecmd

  echo .
  echo ---- ${hname} Created node $hname ----- 
  echo .
  echo ---- ${hname} Manual says to add glibc, libncurses, and tzdata, check later. ---- 
  echo .

  echo copying cr-releas to tmp
  docker cp /Users/pdvbv/Downloads/cockroach-v23.2.2.linux-amd64.tgz ${hname}:/tmp 

  cat <<EOF | docker exec -i $hname sh
    cd /tmp
    # too slow.. curl https://binaries.cockroachdb.com/cockroach-v23.2.2.linux-amd64.tgz | tar -xz
    cat   cockroach-v23.2.2.linux-amd64.tgz | tar -xz
    cp -i cockroach-v23.2.2.linux-amd64/cockroach /usr/local/bin/ 
    echo ... unpacked .. checking which
    which cockroach
    echo .

EOF

  echo . 
  echo ---- ${hname} add components here..   dont start cluster , that is next loop

done

echo .
echo verify docker...
echo .
docker ps 

echo .
echo Now start cr cluster processes...
echo .
    
for nodenr in $nodenrs
do
  
  # define all relevant pieces (no spaces!)
  hname=roach${nodenr}
  
  echo .
  echo ---- ${hname} : start cockoach commponents on node
  echo ---- consider: defining createstmnt first then log and execute
  echo .

  startcmd=` \
    echo docker exec ${hname} nohup cockroach start \
      --insecure \
             --store=/root/var        \
         --http-addr=${hname}:8080   \
          --sql-addr=${hname}:26257  \
    --advertise-addr=${hname}:26357  \
       --listen-addr=${hname}:26357  \
             --join=roach1:26357,roach2:26357,roach3:26357 \& `

  # better, simper version?
  # remove store, use localhost follow example from webpage
  startcmd=` \
    echo docker exec ${hname} nohup cockroach start \
      --insecure \
         --http-addr=localhost:8080   \
       --listen-addr=localhost:26357  \
             --join=roach1:26357,roach2:26357,roach3:26357 \& `

  echo ---- ${hname} : about to start with statrtcmd: 
  echo ---- ${hname} : ${startcmd}
  echo ---- ${hname} :  >> ${LOGFILE}
  echo ${startcmd}      >> ${LOGFILE}

  ${startcmd}

  echo .
  docker exec ${hname} ps -ef 
  echo .
  echo .
  echo ---- ${hname} :  started cluster-commponents on node
  echo .

done

echo .
echo ----- cluster created ,now init.. ------------
echo .

docker exec roach1 cockroach init
 
echo .
echo ----- creation of CR DB done, exiting ------------
echo .

exit 0

# ----------- old code below as inspiration ------------

docker run -d --name=roach1 --hostname=roach1 --net=roachnet \
  -p 26257:26257 -p 8081:8080               \
  -v "vol_roach1:/cockroach/cockroach-data" \
  $IMAGE start \
         --http-addr=roach1:8080      \
          --sql-addr=roach1:26257     \
    --advertise-addr=roach1:26357     \
       --listen-addr=roach1:26357     \
    --insecure   --join=roach1:26357,roach2:26357,roach3:26357

# seems like a good practice from other clusters
sleep 8

echo .
echo .
read -p "First node created ? ... " abc
echo .

# another 6 nodes to add...
# not using for-loop yet bcse of port-mappings

docker run -d --name=roach2 --hostname=roach2 --net=roachnet \
  -p 26258:26257 -p 8082:8080               \
  -v "vol_roach2:/cockroach/cockroach-data" \
  $IMAGE start \
         --http-addr=roach2:8080    \
          --sql-addr=roach2:26257   \
    --advertise-addr=roach2:26357   \
       --listen-addr=roach2:26357   \
    --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 8 

echo .
echo .
# read -p "second node created ? " abc

docker run -d --name=roach3 --hostname=roach3 --net=roachnet \
  -p 26259:26257 -p 8083:8080               \
  -v "vol_roach3:/cockroach/cockroach-data" \
  $IMAGE start \
           --http-addr=roach3:8080    \
            --sql-addr=roach3:26257   \
      --advertise-addr=roach3:26357   \
         --listen-addr=roach3:26357   \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 3

echo .
echo .
read -p "third node created ? " abc


# nr 4, the first one not in the join-list.. ?

docker run -d --name=roach4 --hostname=roach4 --net=roachnet \
  -p 26260:26257 -p 8084:8080               \
  -v "vol_roach4:/cockroach/cockroach-data" \
  $IMAGE start       \
           --http-addr=roach4:8080          \
            --sql-addr=roach4:26257         \
      --advertise-addr=roach4:26357         \
         --listen-addr=roach4:26357         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 8

echo .
echo .
read -p "Fourth node created ? " abc

# nr 5, the second one not in the join-list.. ?

docker run -d --name=roach5 --hostname=roach5 --net=roachnet \
  -p 26261:26257 -p 8085:8080               \
  -v "vol_roach5:/cockroach/cockroach-data" \
  $IMAGE start       \
           --http-addr=roach5:8080          \
            --sql-addr=roach5:26257         \
      --advertise-addr=roach5:26357         \
         --listen-addr=roach5:26357         \
            --sql-addr=roach5:26257         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 8

echo .
echo .
# read -p "fifth node created ? " abc

# nr 6, the third one not in the join-list.. ?

docker run -d --name=roach6 --hostname=roach6 --net=roachnet \
  -p 26262:26257 -p 8086:8080               \
  -v "vol_roach6:/cockroach/cockroach-data" \
  $IMAGE start       \
           --http-addr=roach6:8080          \
            --sql-addr=roach6:26257         \
      --advertise-addr=roach6:26357         \
         --listen-addr=roach6:26357         \
            --sql-addr=roach6:26257         \
      --insecure     --join=roach1:26357,roach2:26357,roach3:26357

sleep 8

echo .
echo .
# read -p "sixth node created ? " abc

# nr 7, the fourth not that is not in the join-list.. ?
# now experiment with using dflt sql-port locally

docker run -d --name=roach7 --hostname=roach7 --net=roachnet \
  -p 26263:26257 -p 8087:8080               \
  -v "vol_roach7:/cockroach/cockroach-data" \
  $IMAGE start       \
           --http-addr=roach7:8080          \
            --sql-addr=roach7:26257         \
      --advertise-addr=roach7:26357         \
         --listen-addr=roach7:26357         \
      --insecure     --join=roach5:26357

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
echo .

# verify via node roach1, ..
docker exec -it roach1 grep 'node starting' /cockroach/cockroach-data/logs/cockroach.log -A 11

# and check with an SQL query ...
docker exec -it roach1 ./cockroach sql --host=roach1:26257 \
  --insecure                                               \
  -e "select node_id, address, is_live from crdb_internal.gossip_nodes order by address;"

echo .
echo Dont Forget, to avoid warnings, but loose some info..for convenience:
echo  => set cluster setting sql.show_ranges_deprecated_behavior.enabled=false ; 
echo . 
echo . 
echo $0 done, cluster running? check it... 
echo .

