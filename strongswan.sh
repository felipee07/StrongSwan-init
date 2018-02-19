apt-get install strongswan libcharon-extra-plugins strongswan-pki

ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/strongswanKey.pem
chmod 600 /etc/ipsec.d/private/strongswanKey.pem
ipsec pki --self --ca --lifetime 3650 --in /etc/ipsec.d/private/strongswanKey.pem --type rsa --dn "C=BR, O=SecBrazil, CN=secbrazil.com" --outform pem > /etc/ipsec.d/cacerts/strongswanCert.pem

ipsec pki --gen --type rsa --size 2048 --outform pem > /etc/ipsec.d/private/vpnHostKey.pem
chmod 600 /etc/ipsec.d/private/vpnHostKey.pem
ipsec pki --pub --in /etc/ipsec.d/private/vpnHostKey.pem --type rsa | ipsec pki --issue --lifetime 730 --cacert /etc/ipsec.d/cacerts/strongswanCert.pem --cakey /etc/ipsec.d/private/strongswanKey.pem  --dn "C=BR, O=SecBrazil, CN=secbrazil.com" --san secbrazil.com --flag serverAuth --flag ikeIntermediate --outform pem > /etc/ipsec.d/certs/vpnHostCert.pem

ipsec pki --gen --type rsa --size 2048 --outform pem > /etc/ipsec.d/private/AlexanderKey.pem
chmod 600 /etc/ipsec.d/private/AlexanderKey.pem
ipsec pki --pub --in /etc/ipsec.d/private/AlexanderKey.pem --type rsa | ipsec pki --issue --lifetime 730 --cacert /etc/ipsec.d/cacerts/strongswanCert.pem --cakey /etc/ipsec.d/private/strongswanKey.pem --dn "C=BR, O=SecBrazil, CN=alexander@secbrazil.com" --san alexander@secbrazil.com --outform pem > /etc/ipsec.d/certs/AlexanderCert.pem

openssl pkcs12 -export -inkey /etc/ipsec.d/private/AlexanderKey.pem -in /etc/ipsec.d/certs/AlexanderCert.pem -name "Alexander's VPN Certificate" -certfile /etc/ipsec.d/cacerts/strongswanCert.pem -caname "secbrazil.com" -out Alexander.p12
