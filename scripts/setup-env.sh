#!/bin/bash

CALLED=$_
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && SOURCED=1 || SOURCED=0

SETUP_SRC=$(realpath ${BASH_SOURCE[0]})
SETUP_DIR=$(dirname $SETUP_SRC)
TOP_DIR=$(realpath $SETUP_DIR/..)
BUILD_DIR=$TOP_DIR/build
THIRD_DIR=$TOP_DIR/third_party

if [ $SOURCED = 0 ]; then
	echo "You must source this script, rather then try and run it."
	echo ". $SETUP_SRC"
	exit 1
fi

if [ ! -z $HDMI2USB_ENV ]; then
  echo "Already sourced this file."
  return
fi

if [ ! -z $SETTINGS_FILE ]; then
  echo "You appear to have sourced the Xilinx ISE settings, these are incompatible with building."
  echo "Please exit this terminal and run again from a clean shell."
  return
fi

echo "             This script is: $SETUP_SRC"
echo "         Firmware directory: $TOP_DIR"
echo "         Build directory is: $BUILD_DIR"
echo "     3rd party directory is: $THIRD_DIR"

# Check the build dir
if [ ! -d $BUILD_DIR ]; then
	echo "Build directory not found!"
	return
fi

# Xilinx ISE
XILINX_DIR=$BUILD_DIR/Xilinx
if [ -f "$XILINX_DIR/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/xreport" ]; then
	export MISOC_EXTRA_CMDLINE="-Ob ise_path $XILINX_DIR/opt/Xilinx/"
	# Reserved MAC address from documentation block, see
	# http://www.iana.org/assignments/ethernet-numbers/ethernet-numbers.xhtml
	export XILINXD_LICENSE_FILE=$XILINX_DIR
	export MACADDR=90:10:00:00:00:01
	#export LD_PRELOAD=$XILINX_DIR/impersonate_macaddress/impersonate_macaddress.so
	#ls -l $LD_PRELOAD
else
	XILINX_DIR=/
fi
echo "        Xilinx directory is: $XILINX_DIR/opt/Xilinx/"

function check_version {
	TOOL=$1
	VERSION=$2
	if $TOOL --version 2>&1 | grep -q $VERSION > /dev/null; then
		echo "$TOOL found at $VERSION"
		return 0
	else
		$TOOL --version
		echo "$TOOL (version $VERSION) *NOT* found"
		echo "Please try running the $SETUP_DIR/get-env.sh script again."
		return 1
	fi
}

function check_import {
	MODULE=$1
	if python3 -c "import $MODULE"; then
		echo "$MODULE found"
		return 0
	else
		echo "$MODULE *NOT* found!"
		echo "Please try running the $SETUP_DIR/get-env.sh script again."
		return 1
	fi
}

# Install and setup conda for downloading packages
echo ""
echo "Checking modules from conda"
echo "---------------------------"
CONDA_DIR=$BUILD_DIR/conda
export PATH=$CONDA_DIR/bin:$PATH

# binutils for the target
check_version lm32-elf-ld 2.25.1 || return 1

# gcc+binutils for the target
check_version lm32-elf-gcc 4.9.3 || return 1


# git submodules
echo ""
echo "Checking git submodules"
echo "-----------------------"

# migen
MIGEN_DIR=$THIRD_DIR/migen




check_import migen || return 1

# misoc
MISOC_DIR=$THIRD_DIR/misoc




check_import misoc || return 1

# litex
LITEX_DIR=$THIRD_DIR/litex




check_import litex || return 1

echo "-----------------------"
echo ""

alias python=python3

UNRANDOM_PRELOAD=$THIRD_DIR/unrandom/libunrandom.so
if [ ! -f $UNRANDOM_PRELOAD ]; then
	echo "unrandom LD_PRELOAD missing! ($UNRANDOM_PRELOAD)"
	return 1
fi
export LD_PRELOAD=$UNRANDOM_PRELOAD

export HDMI2USB_ENV=1
