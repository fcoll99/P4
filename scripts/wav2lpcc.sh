#!/bin/bash

## \file
## \HECHO This file implements a very trivial feature extraction; use it as a template for other front ends.
## 
## Please, read SPTK documentation and some papers in order to implement more advanced front ends.

# Base name for temporary files
base=/tmp/$(basename $0).$$ 

# Ensure cleanup of temporary files on exit
trap cleanup EXIT
cleanup() {
   \rm -f $base.*
}

if [[ $# != 4 ]]; then
   echo "$0 lpc_order num_cepstral_coef input.wav output.lpcc"
   exit 1
fi

lpc_order=$1
num_cepstral_coef=$2
#num_cepstral_coef=lpc_order-1;
inputfile=$3
outputfile=$4

UBUNTU_SPTK=1
if [[ $UBUNTU_SPTK == 1 ]]; then
   # In case you install SPTK using debian package (apt-get)
   X2X="sptk x2x"
   FRAME="sptk frame"
   WINDOW="sptk window"
   LPC="sptk lpc"
   lpc2c="sptk lpc2c"
else
   # or install SPTK building it from its source
   X2X="x2x"
   FRAME="frame"
   WINDOW="window"
   LPC="lpc"
fi

# Main command for feature extration
sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 400 -p 80 | $WINDOW -l 400 -L 512 |
	$LPC -l 400 -m $lpc_order | $lpc2c -m $lpc_order -M $num_cepstral_coef> $base.lpcc

# Our array files need a header with the number of cols and rows:
ncol=$((num_cepstral_coef+1)) # lpc p =>  (gain c1 c2 ... cp) 
nrow=`$X2X +fa < $base.lpcc | wc -l | perl -ne 'print $_/'$ncol', "\n";'`

# Build fmatrix file by placing nrow and ncol in front, and the data after them
echo $nrow $ncol | $X2X +aI > $outputfile
cat $base.lpcc >> $outputfile

exit
