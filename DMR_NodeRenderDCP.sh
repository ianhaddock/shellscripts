#!/bin/bash
#
###################################################################################
#  DMR_NodeRenderDCP.sh                                                           #
#  This script will convert TIF, CIN, and DPX files to DCP MXF and XML files.     #
#  It uses any render nodes set both offline and project projectortest.           #
#  Requires flatten script on LaLynch, and Shake and opendcp on the render nodes. #
#										  #
#  Last updated: 180323 - updated node check and DCP rename flow   - Ian          #
###################################################################################
#

useage () {
cat << EndOfUseage

  # # # DMR_NodeRenderDCP.sh # # #  
 
  This converts TIF, CIN, or DPX images to DCP MXF and XML files 
  using the flatten script on LaLynch and Shake and OpenDCP on 
  the render nodes. 
  
  It checks for P3 or RGB colorspace and converts to XYZ, and logs
  are generated for each tool and node used.

  Note: Make sure colorspace - P3, RGB, XYZ - is in folder name.
  Ex: ./DMR_NodeRenderDCP.sh projectname_date_dom_tlr_3_p3_nr200

EndOfUseage
}

sanitycheck() {
   # sanity check
   if [ $(ls $1 |  wc -l) != $(ls $2 | wc -l) ]; then
      echo "File counts do not match. Something isn't right. Exiting."
      exit 1;
   fi
}


progressbar() {
   # this generates a progress bar based on foldername, count interval, and max count passed to it 
   # ex: " progressbar ${FOLDERNAME}${FLATFOLDER} 2 20 " checks the folder every 2 seconds 20 times

   local TARGETFOLDER=$1
   local COUNTTIME=$2
   local MAXTIME=$3

   until [ $MAXTIME -eq 0 ]; do
      sleep $COUNTTIME
      CURRENTFRAME=$(ls ${TARGETFOLDER} | wc -l);

      echo -ne "  Progress ["
      BARSIZE=$(( $IMAGESTOTAL / $BARLENGTH )); 
      BARCOUNT=$(( $CURRENTFRAME / $BARSIZE ));

      i=0;
      until [ $i -eq $BARCOUNT ]; do
         echo -n "="
         let i=$i+1;
      done; 

      z=$BARCOUNT; 
      until [ $z -eq $BARLENGTH ]; do 
         echo -n " "
         let z=$z+1;
      done

      RUNTIME=`date +%s`;
      echo -ne "] "$(( 200*$BARCOUNT/$BARLENGTH % 2 + 100*$BARCOUNT/$BARLENGTH ))"% "$CURRENTFRAME"/"$IMAGESTOTAL" \r"
   
     # sleep $COUNTTIME;
      let MAXTIME=$MAXTIME-1;

      if [ $CURRENTFRAME -eq $IMAGESTOTAL ]; then
         MAXTIME=0;
         echo " ";
      fi

   done
}


flattenfiles() {
   #create flatten output folder if it does not exist
   [[ -d ${FOLDERNAME}${FLATFOLDER} ]] || mkdir -p ${FOLDERNAME}${FLATFOLDER}

   # check for existing files
   if [ $(ls ${FOLDERNAME}${FLATFOLDER} | wc -l) -gt 0 ]; then
     echo "Files exist in "${FOLDERNAME}${FLATFOLDER}" already. Exiting."
     exit 1;
   fi

   # flatten file names 
   /root/bin/flattenShots.sh ${PWD}/${FOLDERNAME}/  ${EXTENSION}  ${FOLDERNAME}${FLATFOLDER}/${FILENAME} >> ${PWD}/$LOGNAME 2>&1 & 

   if [ $? -eq 1 ]; then
     echo "Could not flatten shots. Bailing out."
     exit 1;
   fi

   echo "Numbering files sequentially for processing. "
   echo `date`": Flattening filenames. " >> $LOGNAME

   progressbar ${FOLDERNAME}${FLATFOLDER} 2 600 ;  # targetfolder, check interval in seconds, max check count

   sanitycheck ${FOLDERNAME} ${FOLDERNAME}${FLATFOLDER} ; # compare two folder counts

   }


cin2tif() {

   # set files per subfolder
   IMAGESPERFOLDER=$((IMAGESTOTAL / TOTALNODES));
   IMAGESPERSHAKE=$((IMAGESPERFOLDER / SHAKEPERNODE));

   #create render node output folder if it does not exist
   [[ -d ${FOLDERNAME}${CINOUTPUTFOLDER} ]] || mkdir -p ${FOLDERNAME}${CINOUTPUTFOLDER}

   # check for existing files
   if [ $(ls ${FOLDERNAME}${CINOUTPUTFOLDER} | wc -l) -gt 0 ]; then
      echo "Files exist in "${FOLDERNAME}${CINOUTPUTFOLDER}" already. Exiting."
      exit 1;
   fi  

   # distibute to render nodes and make sure we get the last odd frame if it exists

   COUNT=0; 

   echo " " 
   echo "Converting Cineon to TIF using "$TOTALNODES" nodes in "$SHAKEPERNODE" batches of "$IMAGESPERSHAKE" files each. This can take a moment. "
   echo `date`": Converting Cineon to TIF using "$TOTALNODES" nodes in "$SHAKEPERNODE" batches of "$IMAGESPERSHAKE" files each. " >> $LOGNAME


   until [ $COUNT -eq $(( $TOTALNODES * $SHAKEPERNODE )) ]; do
  
   if [ $COUNT -eq $(( ($TOTALNODES * $SHAKEPERNODE) - 1)) ]; then
      FFOA=$(( ((IMAGESPERSHAKE * COUNT)) +1));
      LFOA=$IMAGESTOTAL
 
      echo -n `date`": sending batch " >> $LOGNAME
      printf "%02d" $(($COUNT + 1)) >> $LOGNAME
      echo -n " of frames " >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $FFOA >> $LOGNAME
      echo -n "-" >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $LFOA >> $LOGNAME
      echo " to node A0"${NODESAVAIL[$(($COUNT/$SHAKEPERNODE))]}" " >> $LOGNAME

      ssh -f -n root@10.201.8.${NODESAVAIL[$(($COUNT/$SHAKEPERNODE))]} "sh -c '/usr/nreal/shake-linux-v4.10.0830/bin/shake $NODE_PWD/${FOLDERNAME}${FLATFOLDER}/${FILENAME}.#######.${EXTENSION} -cpus 8 $DELOGC -reorder rgb -bytes 2 -fo $NODE_PWD/${FOLDERNAME}${CINOUTPUTFOLDER}/${FILENAME}.#######.tif Auto rgb -t $FFOA-$LFOA >> ${NODE_PWD}/$LOGNAME 2>&1 &'"

      if [ $? -ne 0 ]; then
	echo "Could not ssh to 10.201.8.${NODESAVAIL[$(($COUNT/$SHAKEPERNODE))]}. Bailing out."
	exit 1; 
      fi 
 
      let COUNT=$COUNT+1;

   else
      FFOA=$(( ((IMAGESPERSHAKE * COUNT)) +1 ));
      LFOA=$(( ((IMAGESPERSHAKE * COUNT)) + IMAGESPERSHAKE));
  
      echo -n `date`": sending batch " >> $LOGNAME
      printf "%02d" $(($COUNT + 1)) >> $LOGNAME
      echo -n " of frames " >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $FFOA >> $LOGNAME
      echo -n "-" >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $LFOA >> $LOGNAME
      echo " to node A0"${NODESAVAIL[$(($COUNT/$SHAKEPERNODE))]}" " >> $LOGNAME

      ssh -f -n root@10.201.8.${NODESAVAIL[$(($COUNT/$SHAKEPERNODE))]} "sh -c '/usr/nreal/shake-linux-v4.10.0830/bin/shake $NODE_PWD/${FOLDERNAME}${FLATFOLDER}/${FILENAME}.#######.${EXTENSION} -cpus 8 $DELOGC -reorder rgb -bytes 2 -fo $NODE_PWD/${FOLDERNAME}${CINOUTPUTFOLDER}/${FILENAME}.#######.tif Auto rgb -t $FFOA-$LFOA >> ${NODE_PWD}/$LOGNAME 2>&1 &'"

      if [ $? -ne 0 ]; then
        echo "Could not ssh to 10.201.8.${NODESAVAIL[$(($COUNT/$SHAKEPERNODE))]}. Bailing out."
        exit 1;
      fi 

      let COUNT=$COUNT+1;
   fi
    
   done

   progressbar ${FOLDERNAME}${CINOUTPUTFOLDER} 2 600 ;  # targetfolder, check interval in seconds, max check count

   sanitycheck ${FOLDERNAME} ${FOLDERNAME}${CINOUTPUTFOLDER} ; # compare two folder counts

}


tif2j2k() {

   # set files per subfolder 
   IMAGESPERFOLDER=$((IMAGESTOTAL / TOTALNODES)); 
   IMAGESPERSHAKE=$((IMAGESPERFOLDER / SHAKEPERNODE));

   #create render node output folder if it does not exist
   [[ -d ${FOLDERNAME}${TIFOUTPUTFOLDER} ]] || mkdir -p ${FOLDERNAME}${TIFOUTPUTFOLDER}

   # check for existing files
   if [ $(ls ${FOLDERNAME}${TIFOUTPUTFOLDER} | wc -l) -gt 0 ]; then
     echo "Files exist in "${FOLDERNAME}${TIFOUTPUTFOLDER}" already. Exiting."
     exit 1;
   fi  


  # distibute to render nodes and make sure we get the last odd frame if it exists

  COUNT=0; 

  echo " " 
  echo "Converting TIF files to J2K using "$TOTALNODES" render nodes."
  echo `date`": Converting TIF files to J2K using "$TOTALNODES" render nodes. " >> $LOGNAME

  until [ $COUNT -eq $TOTALNODES ]; do
  
   if [ $COUNT -eq $((TOTALNODES - 1)) ]; then
      FFOA=$(( ((IMAGESPERFOLDER * COUNT)) +1 ));
      LFOA=$IMAGESTOTAL;

      echo -n `date`": sending frames " >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $FFOA >> $LOGNAME
      echo -n " - " >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $LFOA >> $LOGNAME 
      echo " to node A0"${NODESAVAIL[$COUNT]}". " >> $LOGNAME

     ssh -f -n root@10.201.8.${NODESAVAIL[$COUNT]} "sh -c 'sleep 2; /usr/bin/opendcp_j2k $P3 -z -l 1 -s $FFOA -d $LFOA -i $NODE_PWD/${FOLDERNAME}${TIFINPUTFOLDER}/ -o $NODE_PWD/${FOLDERNAME}${TIFOUTPUTFOLDER}/ >> ${NODE_PWD}/$LOGNAME 2>&1 &'"

      if [ $? -ne 0 ]; then
        echo "Could not ssh to 10.201.8.${NODESAVAIL[$COUNT]}. Bailing out."
        exit 1;
      fi 

      let COUNT=$COUNT+1;

   else
      FFOA=$(( ((IMAGESPERFOLDER * COUNT)) +1 ));
      LFOA=$(( ((IMAGESPERFOLDER * COUNT)) + IMAGESPERFOLDER));
   
      echo -n `date`": sending frames " >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $FFOA >> $LOGNAME
      echo -n " - " >> $LOGNAME
      printf "%0${IMAGESCOUNT}d" $LFOA >> $LOGNAME
      echo " to node A0"${NODESAVAIL[$COUNT]}". " >> $LOGNAME

      ssh -f -n root@10.201.8.${NODESAVAIL[$COUNT]} "sh -c 'sleep 2; /usr/bin/opendcp_j2k $P3 -z -l 1 -s $FFOA -d $LFOA -i $NODE_PWD/${FOLDERNAME}${TIFINPUTFOLDER}/ -o $NODE_PWD/${FOLDERNAME}${TIFOUTPUTFOLDER}/ >> ${NODE_PWD}/$LOGNAME 2>&1 &'"

      if [ $? -ne 0 ]; then
        echo "Could not ssh to 10.201.8.${NODESAVAIL[$COUNT]}. Bailing out."
        exit 1;
      fi

      let COUNT=$COUNT+1;
   fi
    
  done

   progressbar ${FOLDERNAME}${TIFOUTPUTFOLDER} 2 600 ;  # targetfolder, check interval in seconds, max check count

   sanitycheck ${FOLDERNAME} ${FOLDERNAME}${TIFOUTPUTFOLDER} ; # compare two folder counts

}


j2k2mxfxml() {

   #create render node output folder if it does not exist
   [[ -d ${DCPNEWNAME}${MXFOUTPUTFOLDER} ]] || mkdir -p ${DCPNEWNAME}${MXFOUTPUTFOLDER}

   # check for existing files
   if [ $(ls ${DCPNEWNAME}${MXFOUTPUTFOLDER} | wc -l) -gt 0 ]; then
     echo "Files exist in "${DCPNEWNAME}${MXFOUTPUTFOLDER}" already. Exiting."
     exit 1;
   fi  


   echo " " 
   echo "Creating MXF and XML for DCP."
   echo `date`": Creating MXF and XML for DCP." >> $LOGNAME  
   COUNT=1;                                    #can only use one node for MXF wrap, uses first one in list

   ssh -f -n root@10.201.8.${NODESAVAIL[$COUNT]} "sh -c 'cd ${NODE_PWD}/${DCPNEWNAME}${MXFOUTPUTFOLDER}/ ; /usr/bin/opendcp_mxf -i ${NODE_PWD}/${FOLDERNAME}${TIFOUTPUTFOLDER} -o ${NODE_PWD}/${DCPNEWNAME}${MXFOUTPUTFOLDER}/${DCPNEWNAME}.mxf ; sleep 3 ; opendcp_xml --reel ${NODE_PWD}/${DCPNEWNAME}${MXFOUTPUTFOLDER}/${DCPNEWNAME}.mxf --title ${DCPNEWNAME} ' "

      if [ $? -ne 0 ]; then
        echo "Could not ssh to 10.201.8.${NODESAVAIL[$COUNT]}. Bailing out."
        exit 1;
      fi


   # monitor MXF and XML creation 
   COUNT=600;
   until [ $COUNT -eq 0 ]; do
      sleep 2;
      let COUNT=COUNT-1;
      if [ $(ls ${DCPNEWNAME}${MXFOUTPUTFOLDER} | wc -l) -ge 5 ]; then
         COUNT=0;
         echo " " 
         echo "Job Complete."
      fi
   done;

   }





######### START OF MAIN #########

SHAKEPERNODE=8;                  # shake needs more threads to be efficient, default 8
BARLENGTH=24;                    # progress bar length, 20 matches the MXF tools
FLATFOLDER="_FlatFiles"          # suffix for sequentially numbered file folder 
TIFOUTPUTFOLDER="_TIF2J2K"       # suffix for TIF to J2K conversion folder
CINOUTPUTFOLDER="_CIN2TIF"       # suffix for Cineon to TIF conversion folder
MXFOUTPUTFOLDER="_DCP"           # suffix for DCP MXF and XML folder 
LOGNAME=${@%/*}"_logfile.log"    # log file of this script

# check if this script is already running 
if pidof -o %PPID -x "DMR_NodeRenderDCP.sh" >/dev/null; then
    echo "Process already running. Exiting."
    exit 1;
fi

# Check for input and show usage if no input is given
if [ $# -ne 1 ]; then
   useage;                
   echo "  No folder passed to script. Exiting.";
   echo " " 
   exit 1;
fi

# check if source folder exists  
if [ ! -d "$@" ]; then 
   useage;
   echo "  Could not find folder. Exiting.";
   exit 1;
fi

# check for DMRrenderNodeControl.py  
if ! hash DMRrenderNodeControl.py 2>/dev/null ; then
   echo " " 
   echo " This script need the DMRrenderNodeControl.py script to run. Exiting." 
   echo " " 
   exit 1;
fi

# check for flatten script
if ! hash flattenShots.sh 2>/dev/null ; then
   echo " " 
   echo " This script need the flattenShots.sh script to run. Exiting." 
   echo " " 
   exit 1;
fi

# adjust pwd for render nodes. This removes the /dmr/ portion
NODE_PWD=$( echo $PWD | cut -c 5- );

# get input file details 
FOLDERNAME=${@%/*}
FULLFILENAME="$(ls $@ | sort -n | head -1)"
EXTENSION="${FULLFILENAME##*.}"
FILENAME="${FOLDERNAME%_*}"

# Get file count in folder
IMAGESTOTAL=$(ls $@ | wc -l);
IMAGESCOUNT=${#IMAGESTOTAL}
 

# tell user what is going to happen.
echo " " 
echo " Source:       "$FOLDERNAME" "
echo " File Type:    "$EXTENSION" " 
echo " Image count:  "$IMAGESTOTAL" " 
echo " "

# checks which nodes are available to use
   printf " Checking nodes, "
   declare -a NODESAVAIL 

   # if DMRrenderNodeControl.py is blocked, flush hosts
   if [[ $(DMRrenderNodeControl.py --getFarmState 1-24 | grep -i flush-hosts ) ]] ; then
      echo -e "unable. Enter password to fix with \"mysqladmin flush-hosts\". "
      ssh -f -n root@10.201.3.121 "sh -c 'mysqladmin flush-hosts'"
      printf " Checking nodes, "
   fi

   # query nodes, if still blocked, use default nodes
   if [[ $(DMRrenderNodeControl.py --getFarmState 1-24 | grep -i flush-hosts ) ]] ; then
      TOTALNODES=5;                            # Default nodes a024, 23, 22, 21, 20
      NODESAVAIL=(24 23 22 21 20);             # last octet of availabe Nodes
      echo -e "unable. Using fallback of $TOTALNODES nodes: ${NODESAVAIL[*]}."
   else
      NODESAVAIL=($(DMRrenderNodeControl.py --getFarmState 1-24 | grep "offline" | awk '{print $1}' | cut -c 3-4) )
      TOTALNODES=${#NODESAVAIL[@]}
      echo -e "$TOTALNODES found: ${NODESAVAIL[*]} "
   fi
   echo " "

echo " This script will use $TOTALNODES render nodes to do the following:"

   DCPNEWNAME=test
   DCPNAME=$FOLDERNAME

   while [ $DCPNAME != $DCPNEWNAME ]; do

     echo " * sequentially number input files in:       "${FOLDERNAME}${FLATFOLDER}" "

     # check for .cin files
     if [[ $EXTENSION == "cin" ]] || [[ $EXTENSION == "CIN" ]]; then
        echo " * convert input CIN to TIF in:              "$FOLDERNAME$CINOUTPUTFOLDER;
        CINFILES=1;
        TIFINPUTFOLDER=$CINOUTPUTFOLDER;
     else
        TIFINPUTFOLDER=$FLATFOLDER;
        CINFILES=0;
     fi
  
     # check for P3 color space and set appropriate flags
     if [[ $DCPNAME == *"_P3"* ]] || [[ $DCPNAME == *"_p3"* ]]; then
        echo " * convert P3 color space TIF to XYZ J2K in: "$FOLDERNAME$TIFOUTPUTFOLDER
        DELOGC=" ";
        P3=" -c p3 ";
     else
        echo " * convert TIF to J2K in:                    "$FOLDERNAME$TIFOUTPUTFOLDER;
        DELOGC=" -delogc 0 0 0 40 720 .6 1.0 100 ";
        P3=" -x ";                                        # stops the rgb to xyz conversion
     fi

     # check for RGB colorspace
     if [[ $DCPNAME == *"_rgb"* ]] || [[ $DCPNAME == *"_RGB"* ]]; then
        echo " * convert RGB to XYZ Colorspace."
        P3=" ";                                 # removing the -x flag forces rgb to xyz conversion
     fi

     echo " * convert J2K to MXF in:                    "$FOLDERNAME$MXFOUTPUTFOLDER;
     echo " * generate XML for the MXF with the title:  "$DCPNAME;
     echo " "
 
     read -p " Press ENTER if correct, or rename DCP: " NEWNAME

     if [[ -z "$NEWNAME" ]]; then
        DCPNEWNAME=${DCPNAME// /_};
     else
        echo " " 
        DCPNAME=${NEWNAME// /_};
     fi

   done



echo `date`": Starting. Node log entries can overlap." >> $LOGNAME   # start log file 

# start converting 
flattenfiles;                                     # flatten files to standardize frame number
if [ $CINFILES -eq 1 ]; then                      # if Cineon files, convert to tif
   cin2tif;
fi
tif2j2k;                                          # convert tif to j2k
j2k2mxfxml;                                       # convert j2k to MXF and create XML

#ENDTIME=`date +%s`;

echo `date`": Finished. Runtime: "$(( ((ENDTIME-STARTTIME)) / 60 ))" minutes."  >> $LOGNAME
echo " "
echo " Runtime: $(($SECONDS/60)) minutes."
echo " Exiting."
echo " " 

exit 0;




