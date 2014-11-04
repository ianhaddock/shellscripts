#!/bin/sh
# Hacked together by Ian Haddock January 10, 2014 

##Check for root
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root" 1>&2
	   exit 1
	fi


## Set Apple Remote Desktop Fields
	doneBefore=$(defaults read /Library/Preferences/com.apple.RemoteDesktop Text3 | cut -c 1-3);
	if [ $doneBefore=="IGN" ];then
		echo "ARD Values look to be set."
	else 
		modelID=$(sysctl hw.model | awk '{print $2}' ); # Get Hardware Type ID

		# Ask user some questions: 
		read -e -p "Who is the main user of this machine: " mainUser 
		read -e -p "What is the asset tag of this machine: " assetTag 
		read -e -p "What is the room number where this machine lives: " roomNumber 

		# write remote desktop text fields 
		defaults write /Library/Preferences/com.apple.RemoteDesktop Text1 "$mainUser"
		defaults write /Library/Preferences/com.apple.RemoteDesktop Text2 "$modelID"
		defaults write /Library/Preferences/com.apple.RemoteDesktop Text3 "$assetTag"
		defaults write /Library/Preferences/com.apple.RemoteDesktop Text4 "$roomNumber"
	fi

##Get ComputerName, remove special characters, and set as boot drive name.
	driveID=$(diskutil info / | grep "Device Identifier" | awk {'print $3'}); #Get Boot Drive Identifier 
	cleanDriveName=$(scutil --get ComputerName | sed 's/[\._ ()-]//g'); #Removes \ . _ and -
	diskutil rename $driveID "$cleanDriveName"

##Update Network settings
	networksetup

##Power Management
	sudo pmset womp 1; #Set Wake On LAN
	#defaults read /Library/Preferences/SystemConfiguration/com.apple.PowerManagement | grep "Wake On LAN" | awk {'print $5'};
	 
	# set charger - AC power - settings
	pmset -c disksleep 0 # removes spindown
	pmset -c displaysleep 30 # 30 min to display sleep
	pmset -c sleep 0 #disable system sleep
	pmset -c autorestart 1 #restart on power outage
	pmset -c ttyskeepawake 1 #keep awake if any remote access is happening
	
	# set battery settings
	pmset -b disksleep 1 # allows spindown
	pmset -b displaysleep 15 # in minutes
	pmset -b sleep 30 #system sleep in minutes
	pmset -b autorestart 0 #restart on power outage
	pmset -b ttyskeepawake 1 #keep awake if any remote access is happening	




exit 0 
