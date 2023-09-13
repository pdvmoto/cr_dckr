#!/usr/bin/sh

# cleanlogs.sh: copy to each node, and execute

cd /cockroach/cockroach-data/logs
ls -l *12T*.log
rm -rf *12T*.log
ls -l *12T*.log
echo logfiles listed...
sleep 1

