#!/usr/bin/env bash

 if [ $(id -u) -eq 0 ] ; then
  echo ""
 else
  echo "Please use sudo here"
  exit 1
fi

while getopts "d:l" Option
do
	case $Option in
	  d ) DEVICE=$OPTARG ;;
          l ) sudo nvme list ; exit ;;
	  ? ) echo "Unknown argument $OPTARG" ; exit ;;
	esac
done

# Check that the provided device is a block special file.
if [[ -b $DEVICE ]] ; then
	echo "The device $DEVICE is found"
else
	echo "The device $DEVICE is NOT found specify with -d"
	exit
fi

# !!! TODO - save the device name to a file in the result directory so we dont have to imply it from the filename.
export FIOFILE=$DEVICE
export BS=4k
export IODEPTH=1
#export SIZE=10g
export SIZE=1g
TIMESTAMP=$(date +%y%m%d_%H%M%S)
DEVICE=$(basename $FIOFILE)
HOSTNAME=$(hostname)
RESULTDIR=fio-$HOSTNAME-$DEVICE-$TIMESTAMP

# Get environmental info for this mountpoint.
# mkdir to store result and enviornment info in
#  - rr-8k-samsung-linux-6.4-ext4-pci2-

if [[ ! -d $RESULTDIR  ]] ; then
	# Create directory and populate with info relevent to 
	# these runs.
	mkdir $RESULTDIR
	sudo nvme list -o json > $RESULTDIR/nvme-list.json
	cat /proc/cpuinfo > $RESULTDIR/cpuinfo
        echo $DEVICE > $RESULTDIR/device-under-test.out
        env > $RESULTDIR/env-vars.out
        cp rr.fio $RESULTDIR/rr.fio
fi


for i in 1 2 4 8 16 32 64 128 256
do
    export IODEPTH=$i
    echo fio rr.fio --output $RESULTDIR/sr-$BS-$IODEPTH-OIO-$DEVICE-out.json --output-format=json
    fio rr.fio --output $RESULTDIR/sr-$BS-$IODEPTH-OIO-$DEVICE-out.json --output-format=json
    sudo chown -R $SUDO_USER: $RESULTDIR
done
echo ""
echo "Done"
echo
python3 ./printout.py $RESULTDIR

