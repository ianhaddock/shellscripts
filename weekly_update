#!/bin/sh 
# hacked by Ian haddock August 19, 2014 
# puts together the weekly file storage check email

# check if drives are mounted, if not, mount drives, tbd

# set variables 
WARNFULL=85
MAXFULL=95
BARLENGTH=40
MEDIA=$(df -H | grep "WCMO_Media");
DELIVERY=$(df -H | grep WCMO_Delivery);


# starts the email 
echo " " 
echo "Hello, weekly stats:"
echo "" 
echo "SAN Usage:"
echo ""
echo $DELIVERY | awk '{print $9" --- "$4" free of "$2"."}';
CURRENTFULL=$(df -H | grep WCMO_Delivery | awk '{print $5+0}');
~/Dropbox/Scripts/percentfull.sh $CURRENTFULL $BARLENGTH

if [ $CURRENTFULL -gt $WARNFULL ]; then
	echo "\n*WARNING* Free space below threshold. Please clear space.\n"
fi;
if [ $CURRENTFULL -gt $MAXFULL ]; then
	echo "*\nCRITICAL* Free space below minimum. Please clear space. \n"
fi;

echo "";

echo $MEDIA | awk '{print $9" --- "$4" free of "$2"."}';
CURRENTFULL=$(df -H | grep WCMO_Media | awk '{print $5+0}');
~/Dropbox/Scripts/percentfull.sh $CURRENTFULL $BARLENGTH
if [ $CURRENTFULL -gt $WARNFULL ]; then
	echo "*\nWARNING* Free space below threshold. Please clear space. *WARNING* \n"
fi;
if [ $CURRENTFULL -gt $MAXFULL ]; then
	echo "*\nCRITICAL* Free space below minimum. Please clear space *CRITICAL* \n"
fi;

echo "" 
# I'm still working on getting DIVArchive reports
echo "Front Porch:"
echo " * SOME Tb Free"
echo "" 
echo "Maintenance:"
echo "* CatDV Worker Node restarted"
echo "* WCMOMacCaption1 checked"
echo "* Brocade Fiber Switches checked"
echo ""
echo "Thanks,"
echo "Ian "
echo ""



