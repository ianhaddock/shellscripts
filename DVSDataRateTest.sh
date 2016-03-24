#!/bin/sh
# Hacked together by Ian Haddock with help from Matt and Derek 
# November 3, 2014 11:33 AM
# Update 1 November 4, 2014 11:43 AM

#TESTFILE=/media/DVS-RT0/dvstemp/test3.txt
#LOGS=/media/DVS-RT0/dvstemp/DVSDataRateTest.log
#SIZE=23k
#count=1
#RUN=73         #24 hours * 3 for each 20 minute run
#WAIT=240

## These are test values
TESTFILE=test3.txt
LOGS=DVSDataRateTest.log
SIZE=2k
count=1
RUN=4
WAIT=1

# Define a timestamp function
timestamp() {
  date +"%T"
}



while [ $count -lt $RUN ]; do 
	
	# Date stamp the logs
	echo $(date)" DVS Storage DD read/write test. Run #"$count >> $LOGS;
	echo " " >> $LOGS;
	
	echo "DD write test #"$count" of "$RUN": dd if=/dev/zero of=/media/DVS-RT0/dvstemp/test3.txt bs=1M count="$SIZE | tee -a $LOGS;
	#dd if=/dev/zero of=/media/DVS-RT0/dvstemp/test3.txt bs=1M count=23k 2>&1 | tee -a $LOGS;
	dd if=/dev/zero of=$TESTFILE bs=1024k count=$SIZE 2>&1 | tee -a $LOGS ;
	echo " " >> $LOGS;
	echo "DD read test #"$count" of "$RUN": dd if=/media/DVS-RT0/dvstemp/test3.txt of=/dev/null bs=1024k" | tee -a $LOGS;
	#dd if=/media/DVS-RT0/dvstemp/test3.txt of=/dev/null bs=1024k 2>&1 | tee -a $LOGS;
	dd if=$TESTFILE of=/dev/null bs=1024k  2>&1 | tee -a $LOGS;
	echo " " >> $LOGS;
	
	count=$((count+1));
	echo "Incrementing counter to "$count" of "$RUN"." | tee -a $LOGS;
	echo " " >> $LOGS;
	printf "Sleeping 20 minutes." | tee -a $LOGS;
	sleep $WAIT
	printf  "." | tee -a $LOGS;
	sleep $WAIT
	printf  "." | tee -a $LOGS;
	sleep $WAIT
	printf  "." | tee -a $LOGS;
	sleep $WAIT
	printf  "." | tee -a $LOGS;
	sleep $((WAIT-120));
	echo "." | tee -a $LOGS;
	echo " " >> $LOGS;
	echo " " >> $LOGS;
done; 

echo "Run completed. Outputs are in: "$LOGS | tee -a $LOGS;

exit; 

