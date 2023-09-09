#!/bin/sh

# rm_cr_clu.sh: clean / remove crdb cluster elements
#
# todo:
#  - check.. doublechck
#  - check order: first stop+remove the containers..
#  - volumes as well ?? verify!
#  - investigate K8S.. better ?
#

# remove containers (are they stopped?)
for node in "roach1 roach2 roach3 roach4 roach5 roach6 roach7"
do
  docker stop $node
  sleep 2
  docker rm $node
done

# volumes, verify cr-stmt that volumes are faster..
docker volume rm vol_roach1
docker volume rm vol_roach2
docker volume rm vol_roach3
docker volume rm vol_roach4
docker volume rm vol_roach5
docker volume rm vol_roach6
docker volume rm vol_roach7

# network, cr wants bridged
docker network rm roachnet

echo . 
echo $0 done, cluster removed? check it... 
echo .

