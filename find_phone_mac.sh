#!/bin/bash
#A ascript which finds  given phone with a spesificl mac address
#By Goran Topic
#echo "to get tha mac address oe need root priviliges, please rerun with sudo";


#get list of networks in compute
NETWORKS=$(ip route | sed '1d' | cut -d' ' -f 1);

#get all hosts in the networks netwosk ip address
for NETCUR in $NETWORKS; do
	HOSTS=$(nmap -sn $NETCUR); 
#| egrep "([0-9]{1,3}\.){3}[0-9]{1,3}" ;
done

echo "result"
echo $HOSTS


