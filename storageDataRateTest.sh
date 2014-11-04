#!/bin/sh
# Hacked together by Ian Haddock with help from Matt and Derek 
# November 3, 2014 11:33 AM

TESTFILE=/media/DVS-RT0/dvstemp/test3.txt
LOGS=/media/DVS-RT0/dvstemp/DVSDataRateTest.log
count=1


# Define a timestamp function
timestamp() {
  date +"%T"
}



while [ $count -le 24 ]; do #24
	
	# Date stamp the logs
	echo " "$(date) >> $LOGS;
	echo " " >> $LOGS;
	
	echo "DD write test "$count": dd if=/dev/zero of=/media/DVS-RT0/dvstemp/test3.txt bs=1M count=23k" | tee -a $LOGS;
	#dd if=/dev/zero of=/media/DVS-RT0/dvstemp/test3.txt bs=1M count=23k 2>&1 | tee -a $LOGS;
	dd if=/dev/zero of=$TESTFILE bs=1024k count=23k 2>&1 | tee -a $LOGS;
	
	echo "DD read test "$count": dd if=/media/DVS-RT0/dvstemp/test3.txt of=/dev/null bs=1024k" | tee -a $LOGS;
	#dd if=/media/DVS-RT0/dvstemp/test3.txt of=/dev/null bs=1024k 2>&1 | tee -a $LOGS;
	dd if=$TESTFILE of=/dev/null bs=1024k  2>&1 | tee -a $LOGS;
	
	count=$((count+1));
	echo "Incrementing counter to "$count".";
	
	printf "Sleeping 60 minutes." | tee -a $LOGS;
	sleep 600
	printf  "." | tee -a $LOGS;
	sleep 600
	printf  "." | tee -a $LOGS;
	sleep 600
	printf  "." | tee -a $LOGS;
	sleep 600
	printf  "." | tee -a $LOGS;
	sleep 600
	printf  "." | tee -a $LOGS;
	sleep 480
	echo "." | tee -a $LOGS;
	echo " " >> $LOGS;
	echo " " >> $LOGS;
done; 

echo "Run completed. Outputs are in: "$LOGS;

exit; 
