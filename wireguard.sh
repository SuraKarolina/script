#!/bin/bash


function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}


function checkOS() {
	# Check OS version
	if [[ -e /etc/debian_version ]]; then
		source /etc/os-release
		OS="${ID}" # debian or ubuntu
		if [[ ${ID} == "debian" || ${ID} == "raspbian" ]]; then
			if [[ ${VERSION_ID} -ne 10 ]]; then
				echo "Your version of Debian (${VERSION_ID}) is not supported. Please use Debian 10 Buster"
				exit 1
			fi
		fi
	elif [[ -e /etc/fedora-release ]]; then
		source /etc/os-release
		OS="${ID}"
	elif [[ -e /etc/centos-release ]]; then
		source /etc/os-release
		OS=centos
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS or Arch Linux system"
		exit 1
	fi
}


function installWireGuard() {
	# Install WireGuard
	if [[ ${OS} == 'ubuntu' ]]; then
		apt-get update
		apt-get install -y wireguard
	# Make sure the directory exists
	mkdir /etc/wireguard >/dev/null 2>&1

	chmod 600 -R /etc/wireguard/

    wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey

    # Add template to config file
	echo "[Interface]
PrivateKey = <PRIVATE KEY HERE>
Address = <CLIENT PEER IP HERE>

[Peer]
Endpoint = vpn.ctrl.txconnected.com:51820
PublicKey = YOE5xUOVoObob6bSToU9EeB/Tx6IbceLnr1lGXj9mGs=
AllowedIPs = 10.1.110.0/24, 10.127.0.0/16, 10.123.0.0/16, 10.128.0.0/16, 10.125.0.0/16, 10.121.0.0/16, 10.126.0.0/16, 10.117.0.0/16, 10.120.0.0/16, 10.118.0.0/16, 10.119.0.0/16, 10.18.0.0/16
Persist = 50" >"/etc/wireguard/wg0.conf"
    fi
}

    # Start the WireGuard VPN
    # systemctl start wg-quick@wg0

    # Check that it started properly
    # systemctl status wg-quick@wg0

    # Verify the connection
    # sudo wg