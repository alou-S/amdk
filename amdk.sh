#!/system/bin/sh

# Enter all apps for OOMD immunity into the array below
APP=("com.termux" "com.zerotier.one" "com.supercell.brawlstars")

if [ $(id -u) != 0 ]
then
  echo "This script won't work unless you are running as root."
  exit
fi

stty -echo
clear

# All variables will be initialized below
x=0
time1=0; time2=0
LMKD=$(pidof -s lmkd)

MINFREE=$(cat /sys/module/lowmemorykiller/parameters/minfree)
ADJ=$(cat /sys/module/lowmemorykiller/parameters/adj)
PSTRING=("[.-.]" "[-.-]" "[^_^]" "[^-^]" "[-_-]" \
  "[._.]" "[,-,]" "['.']" "['-']" "['_']") #10

# Gets PID's of all apps.
check(){
  x=0
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

# Resumes lmkd and sets back minfree and adj values to normal when exiting.
cleanup(){
  kill -CONT $LMKD
  echo $MINFREE > /sys/module/lowmemorykiller/parameters/minfree
  echo $ADJ > /sys/module/lowmemorykiller/parameters/adj
  stty echo
}
trap cleanup EXIT

# Function for simply printing the status of the script.
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
        echo ${APP[$x]}" (${PID[$x]})"
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

# Resume and suspend lmkd every 5 seconds so ART doesn't crash.
  if [[ $(($time0 % 5)) == 0 ]] && [[ $time0 != time2 ]]
  then
    kill -CONT $LMKD
    # Editing sleep time may cause problems
    # Too high values may lmkd enough time to kill immune apps.
    # Setting the value to 0.1 sometimes causes ART to panic after a while.
    sleep 0.2
    kill -STOP $LMKD
  fi

# Check PID's and Reset oom and lmkd values every second
  if [[ $time1 != $time0 ]]
  then
    time1=$time0
    check

# Loop to set the oom_adj for all the apps
    x=0
    while [[ ${PID[$x]} != "" ]]
    do
      if [[ ${PID[$x]} != "NULL" ]]
      then
        echo -17 > /proc/${PID[x]}/oom_adj
      fi
      x=$(($x+1))
    done

    echo 9999 > /sys/module/lowmemorykiller/parameters/adj
    echo 1 > /sys/module/lowmemorykiller/parameters/minfree

    status
  fi

  sleep 0.2
done
