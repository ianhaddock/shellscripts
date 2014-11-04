#!/bin/bash
# Push new printers script.
# by Michael Morena on December 17, 2013
# Last updated December 19, 2013 by Ian Haddock
 
##Check for root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
 
##Get OSX Version 
OSXVersion=$(sw_vers | grep ProductVersion: | awk '{print $2}' | cut -c 4); #output is 6, 7 or 8
 
##Exit if OS10.9 Mavericks 
if [ "$OSXVersion" -eq "9" ]; then
    echo "System is 10.9 Mavericks. Konica driver not available."
    exit 1
fi
 
##Create a temp file to read back the printers to add (in case it is a long list)
##Then list each printer in the HERE DOC below in the format "PrinterNameNoSpaces,IPAddress"
export PrinterList=`/usr/bin/mktemp /tmp/printerlist_XXXXXXXXX`
cat > ${PrinterList} <<EOL
Interactive_Bizhub,192.168.5.73
Accounting_BizHub,192.168.0.29
AP_Bizhub,192.168.0.17
EOL
 
##Function for adding the printer
function AddPrinter()
{
##Printer Driver/PPD
#Quoted so you do not have to escape spaces
PrinterPPD="/Library/Printers/PPDs/Contents/Resources/KONICAMINOLTAC754e.gz"
 
##Printer Options
#can be anything from the CUPS config file
PrinterOptions="-o printer-is-shared=false -o Finisher=FS535 -o KMDuplex=single"
 
##Add the printer, with options
lpadmin -p ${PrinterName} -v lpd://${PrinterAddress} -P "${PrinterPPD}" ${PrinterOptions} -E && echo "Printer ${PrinterName} added!"
}
 
##Install correct PPD if missing
echo -ne "System is OS 10."$OSXVersion". "  # report system version, then:
if [ ! -f $PrinterPPD ]; then
    echo -ne "Drivers are missing, installing Konica drivers. \n"
    curl -O http://printmaster.ignitionprint.lan/curlrepository/Bizhub_Drivers/bizhub_C754_10'$OSXVersion'.pkg
    # curl -O http://192.168.0.44/bizhub_C754_10'$OSXVersion'.pkg -- fallback version on Ian's machine. 
    installer -pkg "bizhub_C754_10"$OSXVersion".pkg" -target /
else
    echo -e "Drivers are installed, adding printers. \n"
fi
 
##Set printer name and IP address
for PrinterL in $(cat ${PrinterList}); do
##Set the name and IP of the machine from the list
export PrinterName=$(echo "${PrinterL}" | cut -d , -f 1)
export PrinterAddress=$(echo "${PrinterL}" | cut -d , -f 2)
 
##IF the printer is not already in the list on the machine, add it
lpstat -p | awk '{print $2}' | grep "${PrinterName}" > /dev/null || AddPrinter
 
##Clean up for the next round
unset PrinterName
unset PrinterAddress
done
 
echo -e "The printers installed are now:\n"
echo "$(lpstat -p)"
 
 
exit 0
