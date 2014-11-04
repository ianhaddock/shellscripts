#!/bin/bash
# Ian Haddock
# November 2012
# This script monitors edit systems and pings when one is not reachable 

# variables and init states. 

Count=0;
StartTimeStamp=$(date +%m-%d-%y@%H:%M:%S);
OnlineCount=0;
OfflineCount=0;
TotalCount=0;

Bay2Status="unknown";
Bay3Status="unknown";
Bay4Status="unknown";
BayAStatus="unknown";
BayBStatus="unknown";
BayCStatus="unknown";
BayDStatus="unknown";
BayEStatus="unknown";
BayFStatus="unknown";
BayGStatus="unknown";
BayHStatus="unknown";
BayIStatus="unknown";
BayJStatus="unknown";
BayKStatus="unknown";
BayLStatus="unknown";
BayMStatus="unknown";
BayNStatus="unknown";
BayOStatus="unknown";
BayPStatus="unknown";
BayQStatus="unknown";
BayRStatus="unknown";
BaySStatus="unknown";
Assist1Status="unknown";
Assist2Status="unknown";
Assist3Status="unknown";
Assist4Status="unknown";
Finish1Status="unknown";
Finish2Status="unknown";
Finish3Status="unknown";
Ingest1Status="unknown";
Ingest2Status="unknown";

Bay2=192.168.1.32
Bay3=192.168.1.15
Bay4=192.168.1.33
BayA=192.168.1.11
BayB=192.168.1.12
BayC=192.168.1.13
BayD=192.168.1.14
BayE=192.168.1.15
BayF=192.168.1.16
BayG=192.168.1.17
BayH=192.168.1.18
BayI=192.168.1.19
BayJ=192.168.1.20
BayK=192.168.1.21
BayL=192.168.1.22
BayM=192.168.1.23
BayN=192.168.1.24
BayO=192.168.1.25
BayP=192.168.1.26
BayQ=192.168.1.27
BayR=192.168.1.28
BayS=192.168.1.29
Assist1=192.168.9.34
Assist2=192.168.9.35
Assist3=192.168.9.36
Assist4=192.168.9.37
Finish1=192.168.9.41
Finish2=192.168.9.42
Finish3=192.168.9.43
Ingest1=192.168.1.38
Ingest2=192.168.1.39

# display device status

while :;  do

LastRunTimeStamp=$(date +%m-%d-%y@%H:%M:%S);

# Placeholder for a percentage online indicator. 
# PercentOnline="$OnlineCount / $TotalCount"; #
# PercentOn=`echo "$PercentOnline" | bc`; # * 100 | bc ))'; # | bc ; #| sed s/\\.[0-9]\\+//;
# echo “scale=2; 1 / 2 * 100″ | bc

clear

echo "Edit station online status. Use Control-C to quit."
echo "Started on $StartTimeStamp"
echo "Last check $LastRunTimeStamp"
echo "Checked $Count times"
echo "$OnlineCount of $TotalCount online"
echo " ";
echo -n "Bay 2 $Bay2Status   ";
echo -n "Bay 3 $Bay3Status   ";
echo  "Bay 4 $Bay4Status   ";
echo -n "Bay A $BayAStatus   ";
echo -n "Bay B $BayBStatus   ";
echo "Bay C $BayCStatus   ";
echo -n "Bay D $BayDStatus   ";
echo -n "Bay E $BayEStatus   ";
echo "Bay F $BayFStatus   ";
echo -n "Bay G $BayGStatus   ";
echo -n "Bay H $BayHStatus   ";
echo "Bay I $BayIStatus   ";
echo -n "Bay J $BayJStatus   ";
echo -n "Bay K $BayKStatus   ";
echo "Bay L $BayLStatus   ";
echo -n "Bay M $BayMStatus   ";
echo -n "Bay N $BayNStatus   ";
echo "Bay O $BayOStatus   ";
echo -n "Bay P $BayPStatus   ";
echo -n "Bay Q $BayQStatus   ";
echo "Bay R $BayRStatus   ";
echo "Bay S $BaySStatus   ";
echo " ";
echo -n "Assist 1 $Assist1Status   ";
echo "Assist 2 $Assist2Status   ";
echo -n "Assist 3 $Assist3Status   ";
echo "Assist 4 $Assist4Status   ";
echo " ";
echo -n "Finish 1 $Finish1Status   ";
echo "Finish 2 $Finish2Status   ";
echo "Finish 3 $Finish3Status   ";
echo " ";
echo -n "Ingest 1 $Ingest1Status   ";
echo "Ingest 2 $Ingest2Status   ";
echo " ";

# if this is the first time skip the wait and ping right away

if (( "$Count" > 0 )) ; 
	then
		echo -n "Waiting 10 minutes. "
		sleep 600
		echo -n "Checking machines..."  
		let Count++
		# echo $Count
	else 
		echo -n "Checking machines..."  
		let Count++
		# echo $Count 
		# sleep 3
	fi

# Reset Online and Offline Counts

OnlineCount=0;
# OfflineCount=0;
TotalCount=0;

# ping each device and set status

ping -c1 $Bay2 > /dev/null && Bay2Status="online " && let OnlineCount++ || Bay2Status="offline" && let TotalCount++; 
ping -c1 $Bay3 > /dev/null && Bay3Status="online " && let OnlineCount++ || Bay3Status="offline" && let TotalCount++; 
ping -c1 $Bay4 > /dev/null && Bay4Status="online " && let OnlineCount++ || Bay4Status="offline" && let TotalCount++; 
ping -c1 $BayA > /dev/null && BayAStatus="online " && let OnlineCount++ || BayAStatus="offline" && let TotalCount++; 
ping -c1 $BayB > /dev/null && BayBStatus="online " && let OnlineCount++ || BayBStatus="offline" && let TotalCount++; 
ping -c1 $BayC > /dev/null && BayCStatus="online " && let OnlineCount++ || BayCStatus="offline" && let TotalCount++; 
ping -c1 $BayD > /dev/null && BayDStatus="online " && let OnlineCount++ || BayDStatus="offline" && let TotalCount++; 
ping -c1 $BayE > /dev/null && BayEStatus="online " && let OnlineCount++ || BayEStatus="offline" && let TotalCount++; 
ping -c1 $BayF > /dev/null && BayFStatus="online " && let OnlineCount++ || BayFStatus="offline" && let TotalCount++; 
ping -c1 $BayG > /dev/null && BayGStatus="online " && let OnlineCount++ || BayGStatus="offline" && let TotalCount++; 
ping -c1 $BayH > /dev/null && BayHStatus="online " && let OnlineCount++ || BayHStatus="offline" && let TotalCount++; 
ping -c1 $BayI > /dev/null && BayIStatus="online " && let OnlineCount++ || BayIStatus="offline" && let TotalCount++; 
ping -c1 $BayJ > /dev/null && BayJStatus="online " && let OnlineCount++ || BayJStatus="offline" && let TotalCount++; 
ping -c1 $BayK > /dev/null && BayKStatus="online " && let OnlineCount++ || BayKStatus="offline" && let TotalCount++; 
ping -c1 $BayL > /dev/null && BayLStatus="online " && let OnlineCount++ || BayLStatus="offline" && let TotalCount++; 
ping -c1 $BayM > /dev/null && BayMStatus="online " && let OnlineCount++ || BayMStatus="offline" && let TotalCount++; 
ping -c1 $BayN > /dev/null && BayNStatus="online " && let OnlineCount++ || BayNStatus="offline" && let TotalCount++; 
ping -c1 $BayO > /dev/null && BayOStatus="online " && let OnlineCount++ || BayOStatus="offline" && let TotalCount++; 
ping -c1 $BayP > /dev/null && BayPStatus="online " && let OnlineCount++ || BayPStatus="offline" && let TotalCount++; 
ping -c1 $BayQ > /dev/null && BayQStatus="online " && let OnlineCount++ || BayQStatus="offline" && let TotalCount++; 
ping -c1 $BayR > /dev/null && BayRStatus="online " && let OnlineCount++ || BayRStatus="offline" && let TotalCount++; 
ping -c1 $BayS > /dev/null && BaySStatus="online " && let OnlineCount++ || BaySStatus="offline" && let TotalCount++; 
ping -c1 $Assist1 > /dev/null && Assist1Status="online " && let OnlineCount++ || Assist1Status="offline" && let TotalCount++; 
ping -c1 $Assist2 > /dev/null && Assist2Status="online " && let OnlineCount++ || Assist2Status="offline" && let TotalCount++; 
ping -c1 $Assist3 > /dev/null && Assist3Status="online " && let OnlineCount++ || Assist3Status="offline" && let TotalCount++; 
ping -c1 $Assist4 > /dev/null && Assist4Status="online " && let OnlineCount++ || Assist4Status="offline" && let TotalCount++; 
ping -c1 $Finish1 > /dev/null && Finish1Status="online " && let OnlineCount++ || Finish1Status="offline" && let TotalCount++; 
ping -c1 $Finish2 > /dev/null && Finish2Status="online " && let OnlineCount++ || Finish2Status="offline" && let TotalCount++; 
ping -c1 $Finish3 > /dev/null && Finish3Status="online " && let OnlineCount++ || Finish3Status="offline" && let TotalCount++; 
ping -c1 $Ingest1 > /dev/null && Ingest1Status="online " && let OnlineCount++ || Ingest1Status="offline" && let TotalCount++; 
ping -c1 $Ingest2 > /dev/null && Ingest2Status="online " && let OnlineCount++ || Ingest2Status="offline" && let TotalCount++; 

echo -n "Cleaning up." 
sleep 2

done

