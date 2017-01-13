#!/bin/bash

export TARGET=video
export PLATFORM=opsis

HISTDIR="historical-build"

if [ ! -d $HISTDIR ]
then
	mkdir $HISTDIR
fi

source scripts/enter-env.sh

# make clean;
# make gateware;
# make gateware-load;
# checks on the serial port that the firmware booted;
# save build with status somewhere;
# repeat

FL_LOG="build/gateware-load.log"

set -x

COUNT=0
while [ 1 ]; do
	echo "Starting build $COUNT"

	echo "> make clean"
	make clean

	echo "> make gateware"
	make gateware

	echo "> start flterm in background"
	#flterm --port /dev/ttyUSB0 --log $FL_LOG &
	scripts/flterm.py /dev/ttyUSB0 --output-only > $FL_LOG &
	FLPROC=$!

	echo "> make gateware-load"
	make gateware-load

	# Sleep to give opsis time to load firmware
	sleep 20

	echo "> kill flterm"
	kill $FLPROC

	echo "> check memtest"
	STATUS="pass"

	grep "Memtest OK" $FL_LOG
	MEMTEST_PASS=$?

	if [ $MEMTEST_PASS -ne 0 ]
       	then
		STATUS="fail"
	fi

	echo "> build: $STATUS"

	echo "> move build folder"
	RESDIR="$HISTDIR/build-${COUNT}-${STATUS}"
	mkdir -p $RESDIR
	mv $FL_LOG "${RESDIR}/"
	mv "build/${PLATFORM}_${TARGET}_lm32" "${RESDIR}/"

	let COUNT=$COUNT+1
done;
