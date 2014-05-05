#!/bin/bash

cd /usr/share/jmxtrans/
#the second operand is the json file to use. below we get its absolute path.
jsonfile="$(readlink -f "$2")"

if [ ! -e $jsonfile ];  then
	echo "jsonfile not found"
	exit
fi

./jmxtrans.sh $1 $jsonfile

