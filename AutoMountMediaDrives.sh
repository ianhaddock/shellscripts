#!/bin/bash
# Ian Haddock
# this is a hack to mount the media drives

# while : ; do
	# clear
	# echo "This is a hack to mount the Media Drives via an Applescript."
	# open /Users/Shared/Mount_Media_Drives_app.app
	echo "Hello. Waiting 5 minutes."
	# sleep 900
	# clear
	
	if [ -d "/Volumes/Media-A1/" ]; then	
			/sbin/mount_afp "afp://192.168.9.34/MEDIA-A1/" "/Volumes/Media-A1/"
		else
			mkdir "/Volumes/Media-A1/"
			/sbin/mount_afp "afp://192.168.9.34/MEDIA-A1/" "/Volumes/Media-A1/"
		fi
		
	if [ -d "/Volumes/Media ASST 2/" ]; then	
			/sbin/mount_afp "afp://192.168.9.35/Media ASST 2/" "/Volumes/Media ASST 2/"
		else
			mkdir "/Volumes/Media ASST 2/"
			/sbin/mount_afp "afp://192.168.9.35/Media ASST 2/" "/Volumes/Media ASST 2/"
		fi
	
	if [ -d "/Volumes/MEDIA_A3/" ]; then	
			/sbin/mount_afp "afp://192.168.9.36/MEDIA_A3/" "/Volumes/MEDIA_A3/"
		else
			mkdir "/Volumes/MEDIA_A3/"
			/sbin/mount_afp "afp://192.168.9.36/MEDIA_A3/" "/Volumes/MEDIA_A3/"
		fi
	
	if [ -d "/Volumes/MEDIA-A4/" ]; then	
			/sbin/mount_afp "afp://192.168.9.37/MEDIA-A4/" "/Volumes/MEDIA-A4/"
		else
			mkdir "/Volumes/MEDIA-A4/"
			/sbin/mount_afp "afp://192.168.9.37/MEDIA-A4/" "/Volumes/MEDIA-A4/"
		fi
		
# done

exit
