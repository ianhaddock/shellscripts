#!/bin/bash
# Ian Haddock
# November 2012
# This script will rip a DVD to the AppleTV 1 spec in Handbrake 

timestamp=$(date +%m%d%y_%H%M%S)

clear 

ECHO "This will rip a DVD to the Desktop using Apple TV settings in Handbrake CLI."
ECHO "" 

if [ -f /usr/bin/HandBrakeCLI ];
then

while true; do
    read -p "OK to continue? " yn
    case $yn in
        [Yy]* ) 
        	read -p "Drag and drop the VIDEO_TS folder and press return: " sourcefile
        	clear
        	ECHO "This will rip a DVD to Apple TV settings in Handbrake CLI."
			ECHO "" 
			ECHO "Working..."
        	/usr/bin/HandBrakeCLI -i $sourcefile -o ~/Desktop/HandbrakeOutput_$timestamp.m4v --preset="AppleTV" 2>~/Documents/HandBrakeCLILog.txt
        	ECHO "Done."
        	printf "\a" ;
        	break;;
        [Nn]* ) 
        	ECHO "Exiting without changes."
        	echo ""
        	exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

else 
	echo "Handbrake CLI not fount. Please install in /etc/bin/ and retry."
	echo "Download: http://handbrake.fr/downloads.php"
	echo ""
	echo ""
	
fi

