#!/bin/sh
# Ian Haddock January 9, 2015

IPLIST=iplist.txt

while read IPLIST
do 
echo exit | telnet $IPLIST
done <iplist.txt

