#!/usr/bin/env bash

#export FIOFILE=/dev/nvme0n1p1
export FIOFILE=/dev/nvme1n1p1


export BS=64k
export IODEPTH=1
export SIZE=10g
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
fi


for i in 1 2 4 8 16 32 64 128 256
do
    export IODEPTH=$i
    echo fio sr.fio --output $RESULTDIR/sr-$BS-$IODEPTH-OIO-$DEVICE-out.json --output-format=json
    fio sr.fio --output $RESULTDIR/sr-$BS-$IODEPTH-OIO-$DEVICE-out.json --output-format=json
done

