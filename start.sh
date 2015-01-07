#!/bin/bash

Color_Off='\e[0m'
Red='\e[0;31m'
BRed='\e[1;31m'
Green='\e[0;32m'

current_path=$(pwd)

DIR=$(basename $current_path)
PORT=`echo $DIR | cut -d- -f2`

if [[ "$DIR" =~ ^[a-z]+-[0-9]+$ ]]
then
	echo -e "${Green}DIR OK ${DIR} ${Color_Off}"
else
	echo -e "${BRed}Incorrect Directory${Color_Off}"
	exit
fi

screen -wipe 2> /dev/null > /dev/null

COUNT=`screen -list | grep -c "$DIR"`

if [ "$COUNT" -gt 0 ]
then
	screens=`screen -list | grep "$DIR" | sed -nr 's/\t(.*)\t.*/\1/p'`
	for s in $screens
	do
		mkdir -p kill_logs
		tail -n100 screenlog.0 > kill_logs/$(date +'%Y.%m.%d_%H:%M:%S').log 2> /dev/null
		echo -e "${BRed}Killing ${s}${Color_Off}"
		screen -S ${s} -X quit
	done
fi

# start stop condition
[ "$1" = "stop" ] && exit

COUNT=`screen -list | grep -c "$DIR"`

if [ "$COUNT" -gt 0 ]
then
	echo "${BRed}Already running!${Color_Off}"
	exit
fi

> screenlog.0

FORWARD="1"

if [ -f "run.sh" ]
then
	source run.sh
	echo -e "${Green}Started ... ${DIR}${Color_Off}"

	if [ "$1" = "headless" ]
	then
		echo "Headless ... exiting"
		exit
	fi
	echo -e "${Green}Attaching screen ...${Color_Off}"
	sleep 2
	screen -r $DIR
else
	echo -e "${BRed}Cannot find run.sh${Color_Off}"
fi
