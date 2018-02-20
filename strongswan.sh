#!/bin/bash

menu() {
	echo '1.  Install Strongswan and create new Certificate'
	echo '2.  Generetate a new Certificate'
}

execute() {
	read -p 'What do you want to do? ' choice	
}

if [ "$1" != "--domain" ] || [ -z "$2" ]
then 
	echo "domain name nedeed !"
	exit
fi

menu
echo
execute

if [ $choice -eq 1 ]
then
	apt-get -qq update && apt-get -qq install strongswan libcharon-extra-plugins strongswan-pki
fi

ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/strongswanKey.pem
chmod 600 /etc/ipsec.d/private/strongswanKey.pem
ipsec pki --self --ca --lifetime 3650 --in /etc/ipsec.d/private/strongswanKey.pem --type rsa --dn "C=CH, O=strongSwan, CN=strongSwan Root CA" --outform pem > /etc/ipsec.d/cacerts/strongswanCert.pem

ipsec pki --gen --type rsa --size 2048 --outform pem > /etc/ipsec.d/private/vpnHostKey.pem
chmod 600 /etc/ipsec.d/private/vpnHostKey.pem
ipsec pki --pub --in /etc/ipsec.d/private/vpnHostKey.pem --type rsa | ipsec pki --issue --lifetime 730 --cacert /etc/ipsec.d/cacerts/strongswanCert.pem --cakey /etc/ipsec.d/private/strongswanKey.pem	--dn "C=CH, O=strongSwan, CN=$2" --san $2 --flag serverAuth --flag ikeIntermediate --outform pem > /etc/ipsec.d/certs/vpnHostCert.pem

ipsec pki --gen --type rsa --size 2048 --outform pem > /etc/ipsec.d/private/AlexanderKey.pem
chmod 600 /etc/ipsec.d/private/AlexanderKey.pem
ipsec pki --pub --in /etc/ipsec.d/private/AlexanderKey.pem --type rsa | ipsec pki --issue --lifetime 730 --cacert /etc/ipsec.d/cacerts/strongswanCert.pem --cakey /etc/ipsec.d/private/strongswanKey.pem --dn "C=CH, O=strongSwan, CN=alexander@$2" --san alexander@$2 --outform pem > /etc/ipsec.d/certs/AlexanderCert.pem

openssl pkcs12 -export -inkey /etc/ipsec.d/private/AlexanderKey.pem -in /etc/ipsec.d/certs/AlexanderCert.pem -name "Alexander's VPN Certificate" -certfile /etc/ipsec.d/cacerts/strongswanCert.pem -caname "strongSwan Root CA" -out Alexander.p12
