#!/bin/bash

if [ $(which openvpn) -z ] 2> /dev/null || [ $(whoami) != 'root' ] 2> /dev/null
then
	echo ' [*] Run as root and openvpn are needed for this script'
	exit
fi
cd /root/VPN/VPNBOOK
rm *.*
wget -q http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro2.zip -O /root/VPN/VPNBOOK/euro2.zip
for ITEM in $(ls /root/VPN/VPNBOOK/ | grep .zip);do unzip -qq /root/VPN/VPNBOOK/$ITEM;done
for ITEM in $(ls /root/VPN/VPNBOOK/);do echo -e '\nauth-user-pass "creds"' >> $ITEM;done
rm /root/VPN/VPNBOOK/*.zip
mkdir -p /root/VPN/
mkdir -p /root/VPN/VPNBOOK/
echo vpnbook > /root/VPN/VPNBOOK/creds;curl -s www.vpnbook.com | grep Password | tr -d ' ' | head -n 1 | cut -d '>' -f 3 | cut -d ':' -f 2 | cut -d '<' -f 1 >> /root/VPN/VPNBOOK/creds
if [ ! -f /etc/resolv.conf.bak ] 2> /dev/null
then
	mv /etc/resolv.conf /etc/resolv.conf.bak
fi
echo -e 'nameserver 213.73.91.35\nnameserver 194.150.168.168' > /etc/resolv.conf
CURRIP=$(curl -s icanhazip.com)
echo " [*] Current IP: $CURRIP"
echo " [*] Connecting to VPN.."
openvpn /root/VPN/VPNBOOK/vpnbook-euro2-tcp80.ovpn &> /dev/null&
sleep 8
NEWIP=$(curl -s icanhazip.com)
while [ $CURRIP == $NEWIP ]
do
	sleep 2
	NEWIP=$(curl -s icanhazip.com)
done
echo " [*] New IP: $NEWIP"
echo -e " [*] VPN setup complete.\n [*] Run: [ kill $! ] to stop using it.\n"
