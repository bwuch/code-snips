SERVER=http://www.example.com/cc/
OUTFILE=/tmp/runme.sh

echo '#!/bin/sh' > $OUTFILE

echo -e '\n' >> $OUTFILE
echo "printf 'This script is passing MAC address, hostname, and IP address to:\n   $SERVER \nfor commands to execute on this specific client.  \nWe will then sleep for 5 seconds and execute our combined script from \n$OUTFILE.\n\n'" >> $OUTFILE

# Find MAC address
read MAC </sys/class/net/eth0/address
MAC=$(echo $MAC | sed 's/://g')
echo -e "echo --- Commands specific to MAC address: $MAC \n" >> $OUTFILE
curl $SERVER$MAC.txt -fs >> $OUTFILE

# IP address
IPADDR=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo -e "echo --- Commands specific to IP: $IPADDR \n" >> $OUTFILE
curl $SERVER$IPADDR.txt -fs >> $OUTFILE

# Hostname
echo -e "echo --- Commands specific to hostname: $(hostname) \n" >> $OUTFILE
curl $SERVER$(hostname).txt -fs >> $OUTFILE

# if we find any windows line breaks convert them to linux style
sed -i.bak 's/\r$//' $OUTFILE

echo -e "Sleep 5 seconds before running our script \n"
sleep 5

chmod +x $OUTFILE
$OUTFILE
