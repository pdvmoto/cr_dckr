#!/bin/ksh

echo .
echo docker containers with IPs
echo 
echo container  IP

docker ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}'

echo .
ech ------------------------ 


