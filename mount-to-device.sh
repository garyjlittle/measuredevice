#!/usr/bin/env bash

MOUNTPOINT=$1
declare -a MOUNTINFO=( $(mount | grep $MOUNTPOINT) )

device=${MOUNTINFO[0]}
fstype=${MOUNTINFO[4]}

echo Device: $device fstype $fstype

