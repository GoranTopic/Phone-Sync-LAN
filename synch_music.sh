#!/bin/bash
# synch_music.sh
# A ascript which uses find_phone_mac.sh to look for the given ip address of the target, then it attempts to rsync into it with on port 8022 to sync the Music forlder.
# By Goran Topic


REMOTE_DIR="~/storage/external-1/";
LOCAL_DIR=~/Music;
PREVIOUS_IPS="./previous_ips.txt"
PASSWORD="";
PHONE_NAME="Galaxy-S8.lan";
PHONE_MAC="30:07:4D:10:DC:A9";
USERNAME="u0_a267";
PORT="8022"
DEBUGGING=false

save_ip(){
	# Looks if ip is in list already if not save it.

	$DEBUGGING && echo "saving ip: $1";

	# check is file exists, if not make
	if [ ! -f "$PREVIOUS_IPS" ]; then
		touch $PREVIOUS_IPS;	
	fi

	# check is ip addres already in list
	for ip in $(cat $PREVIOUS_IPS); do
		if [ $ip == $1 ]; then 
			$DEBUGGING && echo "ip already there";
			return 0;
		fi
	done
	echo $IP >> $PREVIOUS_IPS;
}

check_previous_ips() {
	# A fuction which check if the phone with the given name or mac 
	# has been assigned and ip in the list of previous ip 
	
	# check is file exists, if not exit
	if [ ! -f "$PREVIOUS_IPS" ]; then
		echo "no previous ips found, goodbye!";
		exit 1;	
	fi

	# go throught the list of ips
	for ip in $(cat $PREVIOUS_IPS); do
		VAR=$(nmap -F $ip);

		if [[ $VAR == *"$PHONE_NAME"* ]]; then 
			echo "Phone found.";
			IP="$ip";
			return 0;
		elif [[ $VAR == *"$PHONE_MAC"* ]]; then 
			echo "Phone found."
			IP="$ip";
			return 0;
		fi
		echo "Phone not found in list of previus ips, sorry";
		echo "goodbye...";
		exit 1;
	done
}



#look for phone in local network
echo "Looking for phone on local network...";
IP=$( ./find_known_host_ip.sh $PHONE_NAME $PHONE_MAC )

if [[ -z "$IP" ]]; then
	 $DEBUGGING && echo $IP;
   echo "I was not able to find a phone host, is it connected to the shame network?";
   echo "Checking previous ip addresses...";
	 check_previous_ips;	
else
	echo "Phone found.";
	# save this ip address to check later then an ip is not found
	save_ip $IP;
fi

# Attempt to connect to phone via rsync
echo "Attempting to connect via ssh, port $PORT with Rsync...";
if rsync  -vrhp --delete --progress --rsh="ssh -p$PORT" $LOCAL_DIR $USERNAME@$IP:$REMOTE_DIR; then 
	echo "Successfuly updated Music on Phone =)";
else
	echo "Could not sync music on phone =,(";
fi
	




