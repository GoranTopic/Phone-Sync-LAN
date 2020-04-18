#!/bin/bash
# find_known_host_ip.sh
# A ascript which finds given phone with a given mac address written on known_hosts file
#	this script can be run with sudo so that it does an check on the MAC address as well, but it does not have to.
# By Goran Topic
# echo "to get tha mac address oe need root priviliges, please rerun with sudo";

DEBUGGING=false
if [ $# -eq 0 ]; then
    echo "No arguments passed, please pass the device name or MAC Address"
		exit 1;
fi

# sed 1d is used to get of the frist line.
# while head -n -1 is used to get rid of the last

# get list of networks in compute
NETWORKS=$(ip route | sed '1d' | cut -d' ' -f 1);

# get all hosts in the networks netwosk ip address
for NETCUR in $NETWORKS; do
	HOSTS+=$(nmap -sn $NETCUR | sed '1d' | head -n -1); 
done

# declare declare a array 
declare -a hosts_ar; 
index=0;

IFS=$'\n'
for line in $HOSTS; do 
	if [[ $line == *"Nmap scan report for"* ]]; then
		((index++))
		# get host name
		hosts_ar[index]="${hosts_ar[index]} $( echo ${line//for/:} | cut -d\: -f2 | cut -d' ' -f2 )" ;
	fi

	# get ip address 
	hosts_ar[index]="${hosts_ar[index]} $( echo $line | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}" ) ";

	# get MAC address 
	hosts_ar[index]="${hosts_ar[index]}  $( echo $line | egrep -o "([a-fA-F0-9]{2}\:){5}[a-fA-F0-9]{2}" )";

done
unset IFS;


$DEBUGGING && echo "-----------------------------------";

for line in "${hosts_ar[@]}"; do
	for host in $line;do
		for known in $@; do
			$DEBUGGING && echo "$host - $known";
			if [[ "$host" == "$known" ]] ; then 
				$DEBUGGING && echo `echo $line` ;
				# A known host was found
				echo $line | cut -d' ' -f2 ;
				exit 0;
			fi
		done
	done
done

# if known host was not found
exit 1;


