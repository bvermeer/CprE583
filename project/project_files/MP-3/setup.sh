#####################################################################
# Joseph Zambreno
# setup.sh - shell configuration for LEON-based labs
######################################################################


# Confirm that you have not already run the setup.sh
if [ "$LEON_SETUP" == "1" ]; then
  printf "Error: LEON_SETUP already defined.\n"
  printf "Please open a new terminal to apply new changes, or set the \n"
  printf "configuration variables directly.\n"
  return 1
fi

export LEON_SETUP="1"


# Xilinx / Modelsim version numbers. No need to change these
export XLNX_VER=13.4
export ARCH_VER=64
export VSIM_VER=10.1c
export GCC_VER=4.4.2

SDIR=`dirname "$BASH_SOURCE"`
export CDIR=`readlink -f "$SDIR"`


printf "Setting up environment variables for %s-bit Xilinx tools, version %s..." $ARCH_VER $XLNX_VER 
source /remote/Xilinx/$XLNX_VER/settings$ARCH_VER.sh
printf "done.\n"

printf "Setting up path for %s-bit Modelsim tools, version %s..." $ARCH_VER $VSIM_VER
export PATH=$PATH:/remote/Modelsim/$VSIM_VER/modeltech/linux_x86_64/
printf "done.\n"

printf "Setting up license file..."
export LM_LICENSE_FILE=1717@io.ece.iastate.edu:27006@io.ece.iastate.edu
printf "done.\n"

printf "Settting up path to local tools..."
export PATH=$PATH:$CDIR/utils/grmon/linux/:$CDIR/utils/sparc-elf-$GCC_VER/bin/
printf "done.\n"


export SVN_EDITOR="vim"
