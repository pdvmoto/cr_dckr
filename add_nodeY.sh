#!/bin/sh

# add_nodeC.sh worker node from yb container, scripts
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

# use nodeX, to have a neutral node in the network,
docker run -d --network roachnet  \
  --hostname nodeC --name nodeC   \
  yugabytedb/yugabyte             \
  yugabyted start --background=false --ui=true


echo .
echo .
echo nodeC added to roachnet ... 
echo .

