#!/bin/bash

# assign inputs
while getopts i:r:o:m:c:a:d:t:n:z:y:x:w: option
do
case "${option}"
in

# necessary
i) INPUT_SEQ=${OPTARG};;
r) REF_SEQ=${OPTARG};;
o) OUTPUT=${OPTARG};;

# optional nanocount
m) MAPPING_TOOL=${OPTARG};;
c) COUNTING_TOOL=${OPTARG};;
a) ANNOTATION=${OPTARG};;
d) DESEQ=${OPTARG};;

# optional modules
t) NANOTAIL=${OPTARG};;
n) NANOMOD=${OPTARG};;

# tool options
z) FILT_OPTION=${OPTARG};;
y) MAPPING_OPTION=${OPTARG};;
x) COUNT_OPTION=${OPTARG};;
w) PLOT_OPTION=${OPTARG};;

esac
done

#####################################################################################################

echo " <mop_parameters>  input: 	$INPUT_SEQ"
echo " <mop_parameters>  reference: 	$REF_SEQ"
echo " <mop_parameters>  output:	$OUTPUT"
if [ $COUNTING_TOOL == htseqcount ]; then
	echo " <mop_parameters>  annotation:	$ANNOTATION"

fi
echo ""
echo " <mop_parameters>  filter:	nanofilt	($FILT_OPTION)"
echo " <mop_parameters>  map:		$MAPPING_TOOL	($MAPPING_OPTION)"
echo " <mop_parameters>  count:	$COUNTING_TOOL	($COUNT_OPTION)"
echo " <mop_parameters>  plot:	nanoplot	($PLOT_OPTION)"
echo ""
echo " <mop_parameters>  DESeq:	$DESEQ"
echo " <mop_parameters>  NanoTail:	$NANOTAIL"
echo " <mop_parameters>  NanoMod:	$NANOMOD"
echo ""