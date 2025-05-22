SERVER=http://www.example.com/cc/
GUESTSTORE_BASEDIR=/custom/cc/
OUTFILE=/tmp/runme.sh

echo 'Running common control background script'

echo '#!/bin/sh' > ${OUTFILE}
echo -e '\n' >> ${OUTFILE}
echo "printf 'This script is collecting commands to execute on this specific client.  \nIt is checking ${SERVER} and GuestStore path ${GUESTSTORE_BASEDIR}. \nWe will then sleep for 5 seconds and execute our combined script from \n${OUTFILE}.\n\n'" >> ${OUTFILE}

# ==================== GATHER SYSTEM INFO ====================
# Find this system MAC address
read MAC </sys/class/net/eth0/address
MAC=$(echo ${MAC} | sed 's/://g')

# Find this system IP address
IPADDR=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

# Find guestinfo script name
GI_CCSCRIPT=$(/usr/local/bin/vmware-rpctool 'info-get guestinfo.ccScript')

# ==================== WEB ====================
# Web - This MAC Address
curl ${SERVER}${MAC}.txt -fs >> ${OUTFILE}
echo -e "echo --- Web commands for MAC address: $MAC \n" >> ${OUTFILE}

# Web - IP address
echo -e "echo --- Web commands for IP: $IPADDR \n" >> ${OUTFILE}
curl $SERVER$IPADDR.txt -fs >> ${OUTFILE}

# Web - Hostname
echo -e "echo --- Web commands for hostname: $(hostname) \n" >> ${OUTFILE}
curl $SERVER$(hostname).txt -fs >> ${OUTFILE}

# Web - ALL
echo -e "echo --- Web commands for all clients \n" >> ${OUTFILE}
curl ${SERVER}all.txt -fs >> ${OUTFILE}

# ==================== GUEST STORE ====================
# if GuestInfo ccScript is defined, retrieve it with gueststore getcontent
if echo ${GI_CCSCRIPT} | grep -iq "sh$\|txt$"; then
  echo -e "echo --- GuestStore commands for guestinfo.ccScript: ${GI_CCSCRIPT} \n" >> ${OUTFILE}
  /usr/local/bin/vmware-toolbox-cmd gueststore getcontent ${GUESTSTORE_BASEDIR}${GI_CCSCRIPT} /tmp/cc-${GI_CCSCRIPT}
  if [ -f /tmp/cc-${GI_CCSCRIPT} ]; then
    cat /tmp/cc-${GI_CCSCRIPT} >> ${OUTFILE}
  fi
fi

# GuestStore - ALL
/usr/local/bin/vmware-toolbox-cmd gueststore getcontent ${GUESTSTORE_BASEDIR}cc-all.txt /tmp/cc-all.txt
if [ -e /tmp/cc-all.txt ]; then
  echo -e "echo --- GuestStore commands for cc-all script \n" >> ${OUTFILE}
  cat /tmp/cc-all.txt >> ${OUTFILE}
fi

# ==================== CLEANUP AND RUN ====================
# if we find any windows line breaks convert them to linux style
sed -i.bak 's/\r$//' ${OUTFILE}

echo -e "Sleep 5 seconds before running our script \n"
sleep 5

chmod +x ${OUTFILE}
${OUTFILE}

echo 'Press enter to return to the prompt.'