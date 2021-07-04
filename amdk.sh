#!/system/bin/sh

# Enter all apps for OOMD immunity into the array below
APP=("com.termux" "com.zerotier.one" "com.supercell.brawlstars")
clear

if [ $(id -u) != 0 ]
then
  echo "This script won't work unless you are running as root."
  exit
fi

# All variables will be initialized below
x=0

check(){
  while [[ ${APP[$x]} != "" ]]
  do
    temppid=$(pidof ${APP[$x]})

    if [[ $temppid == "" ]]
    then
      PID[$x]="NULL"
      reprint=1
    elif [[ ${PID[$x]} != $temppid ]]
    then
      PID[$x]=$temppid
      reprint=1
    fi
    x=$((x+1))
  done
}

stty -echo
clear

LMKD=$(pidof -s lmkd)

time1=0; time2=0
x=0

MINFREE=$(cat /sys/module/lowmemorykiller/parameters/minfree)
ADJ=$(cat /sys/module/lowmemorykiller/parameters/adj)
PSTRING=("[.-.]" "[-.-]" "[^_^]" "[^-^]" "[-_-]" \
  "[._.]" "[,-,]" "['.']" "['-']" "['_']") #10

# Resumes lmkd and sets back minfree and adj values to normal when exiting.
cleanup(){
  kill -CONT $LMKD
  echo $MINFREE > /sys/module/lowmemorykiller/parameters/minfree
  echo $ADJ > /sys/module/lowmemorykiller/parameters/adj
  stty echo
}
trap cleanup EXIT

# Function for simply printing the status of the script. (Mostly useless)
status(){
  if [[ $reprint == 1 ]]
  then
    clear
    echo "Android Memory Daemon Kryo"
    echo "https://github.com/alou-S/amdk"
    echo
    echo "To either add or remove apps edit the \"APP\" array in the 4th line of script."
    echo "If any apps are not in this list, they were not detected."
    echo
    echo "OOMD immunity is active for the following apps:"
    x=0
    while [[ ${APP[$x]} != "" ]]
    do
      if [[ ${PID[$x]} != "NULL" ]]
      then
        echo ${APP[$x]}

      fi
      x=$(($x+1))
    done

    echo
    printf ${PSTRING[$((RANDOM % 7))]}
    reprint=0
  else
    printf "\r${PSTRING[$((RANDOM % 7))]}"
  fi
}

while true
do
	time0=$(date +%s)

# To suspend LMKD immediately after resuming it.
	if [[ $y == 1 ]]
	then
		kill -STOP $LMKD
		y=0
	fi
# Resumes lmkd every 5 seconds so that ART doesn't panik.
  if [[ $(($time0 % 5)) == 0 ]] && [[ $time0 != $time2 ]]
	then
		time2=$time0

		kill -CONT $LMKD
		y=1
	fi

# Reset oom and lmkd values every second
	if [[ $time1 != $time0 ]]
	then
		time1=$time0
    x=0
    check
# Loop to set the oom_adj for all the apps
    while [[ ${PID[$x]} != "" ]]
    do
      echo -17 > /proc/${PID[x]}/oom_adj
      x=$(($x+1))
    done

		echo 9999 > /sys/module/lowmemorykiller/parameters/adj
		echo 1 > /sys/module/lowmemorykiller/parameters/minfree

    status
	fi

# Editing sleep time may cause problems
# Too high values may give lmkd enough time to kill apps (Since lmkd is sent to sleep the cycle after waking it up)
# Setting the value to 0.1 sometimes causes ART to panic after a while.
	sleep 0.15
done
