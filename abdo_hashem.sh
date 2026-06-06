#! bin/bash

check_adapter() {
	wlan=$(ifconfig wlan0 | head -n 1 | awk '{print $2}' | grep -i "running")
	ether=$(ifconfig eth0 | head -n 1 | awk '{print $2}' | grep -i "running")
	if [ $wlan ]; then
		adapter="wlan0"
	elif [ $ether ]; then
		adapter="eth0"
	else
		echo "You not connection internet"
		exit 1
	fi
	echo "Running"
}
current_connection() {
	ping -W 4 -c 4 "10.0.0.1" &> /dev/null
	if [ $? -ne 0 ]; then
		echo "You not connected to 5G"
	fi
}
check_internet() {
	ping -W 4 -c 4 "google.com" &> /dev/null
	if [ $? -eq 0 ]; then
		echo -e "Your internet connected\nEnjoy now"
		exit 1
	fi
}

change_mac() {
	ifconfig $1 down
	macchanger -m $2 $1 1> /dev/null
	if [ $? -ne 0 ]; then
		ifconfig wlan0 up
		exit 1
	fi
	ifconfig $1 up
}
run() {
	check_adapter
	check_internet
	echo "the process take sometimes because subnet network contain on 65536 ip"
	addresses=$(arp-scan -l | grep -i -v "vmware" | head -n -3 | tail -n +3 | awk '{print $2}')
	if [ $? -ne 0 ]; then
		exit 1
	fi
	current_mac=$(ifconfig "$adapter" | grep -i 'ether' | awk '{print $2}')
	for mac in $addresses; do
		if [ "$current_mac" = "$mac" ]; then
			continue
		fi
		echo "$mac"
		change_mac $adapter $mac
		check_internet
	done
	echo "Try again later"
}

run
