#!/bin/bash
# Ian Haddock
# January 2013
# This script monitors workstation load

# cd ~/Sites/
# 
# if ! [ -f $pwd/PerformanceMonitoring ]; do
# 	mkdir PerformanceMonitoring
# else 


# Runs as an infinite loop -- run in the background.
 
while : ; do

	# Log timestamp and log file date stamp
	
	Timestamp=$(date +%m-%d-%y_%H:%M:%S);
	Datestamp=$(date +%m%d%y);

	# Start log file
	echo -n "$Timestamp, " >> ~/Documents/PerformanceLoadTest_$Datestamp.txt
	
	# Get load average -- top run twice to get non zero results
	top -n 5 -stats pid,command,cpu,th,pstate,time -o CPU -O TIME -l2 | grep "Load Avg:" > /tmp/PerfMonitor.txt
	
	# Get last 5 minutes load value
	PerfLoad=$(sed '1d' /tmp/PerfMonitor.txt | awk {'print $4'} ); # >> ~/Documents/PerformanceLoadTest_$Datestamp.txt
	
	# Write last 5 minute load value to log file
	echo -n "$PerfLoad " >> ~/Documents/PerformanceLoadTest_$Datestamp.txt
	
	# Get applications using the most CPU
	top -n 1 -stats command,cpu,time -o CPU -O TIME -l2 > /tmp/PerfMonitor.txt
	
	# Parse out the top app
	PerfApp=$(sed '1,25d' /tmp/PerfMonitor.txt ); 
	
	# Write top app to log
	echo "$PerfApp " >> ~/Documents/PerformanceLoadTest_$Datestamp.txt
	
	# echo "waiting" # used for testing only. 
	
	# Wait 5 minutes
	sleep 300
	
done

# fi

exit
