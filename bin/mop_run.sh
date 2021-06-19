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
## making output name
name_output="$(basename $INPUT_SEQ)"
name_output="${name_output/%.*/.}"

## make tempdir and copy files to tempdir
echo -e " <mop_run> \e[33m making temp directory \e[39m"

tempdir=mop_tempdir
input=$tempdir/input
output=$tempdir/output
mkdir $tempdir
mkdir $input
mkdir $output

input_seq=temp_input_seq.sh
ref_seq=temp_input_seq.sh

cp $INPUT_SEQ $input/input_seq.sh
cp $REF_SEQ $input/ref_seq.sh

## write parameters in a file
echo " <mop_parameters>  input:	$INPUT_SEQ" >> $output/parameters.txt
echo " <mop_parameters>  reference:	$REF_SEQ" >> $output/parameters.txt
echo " <mop_parameters>  output:	$OUTPUT" >> $output/parameters.txt
if [ $COUNTING_TOOL == htseqcount ]; then
	echo " <mop_parameters>  annotation:	$ANNOTATION" >> $output/parameters.txt

fi
echo "" >> $output/parameters.txt
echo " <mop_parameters>  filter:	nanofilt	($FILT_OPTION)" >> $output/parameters.txt
echo " <mop_parameters>  map:		$MAPPING_TOOL	($MAPPING_OPTION)" >> $output/parameters.txt
echo " <mop_parameters>  count:	$COUNTING_TOOL	($COUNT_OPTION)" >> $output/parameters.txt
echo " <mop_parameters>  plot:	nanoplot	($PLOT_OPTION)" >> $output/parameters.txt
echo "" >> $output/parameters.txt
echo " <mop_parameters>  DESeq:	$DESEQ" >> $output/parameters.txt
echo " <mop_parameters>  NanoTail:	$NANOTAIL" >> $output/parameters.txt
echo " <mop_parameters>  NanoMod:	$NANOMOD" >> $output/parameters.txt

## unpacking sequences
echo -e " <mop_run> \e[33m unpacking sequence files \e[39m"

gunzip -c $input/ref_seq.sh > $input/ref_seq.fna

## filtering
echo ""
echo -e " <mop_run> \e[34m filtering sequence with NanoFilt \e[39m"

filt_output="${name_output/%.*/_nanofilt.fna}"

gunzip -c $input/input_seq.sh | NanoFilt $FILT_OPTION > $output/$filt_output

## quality report
#echo ""
#echo -e " <mop_run> \e[34m checking quality with FastQC \e[39m"

#mkdir $output/FastQC_report
#mkdir $output/FastQC_report/raw
#mkdir $output/FastQC_report/filt

#gunzip -c $input/input_seq.sh > $input/input_seq.fna

#fastqc $input/input_seq.fna -o $output/FastQC_report/raw
#fastqc $output/$filt_output -o $output/FastQC_report/filt

## running mapping tool

if [ $MAPPING_TOOL == "graphmap2" ]; then
	echo -e " <mop_run> \e[34m aligning reads with graphmap2 \e[39m"

	mapped_output="${name_output/%.*/_graphmap2.bam}"

	bin/graphmap2/bin/Linux-x64/graphmap2 align $MAPPING_OPTION -r $input/ref_seq.fna -d $output/$filt_output -o $output/$mapped_output

elif [ $MAPPING_TOOL == "minimap2" ]; then
	echo -e " <mop_run> \e[34m aligning reads with minimap2 \e[39m"

	mapped_output="${name_output/%.*/_minimap2.bam}"

	minimap2 $MAPPING_OPTION $input/ref_seq.fna $output/$filt_output -o $output/$mapped_output

fi

## running counting tool
if [ $COUNTING_TOOL == "htseqcount" ]; then
	echo -e " <mop_run> \e[34m counting mapped reads with HTseqCount \e[39m"

	cp $ANNOTATION $input/annotation.gff

	counts_output="${name_output/%.*/_htseqcount.count}"

	htseq-count -f bam $COUNT_OPTION $output/$mapped_output $input/annotation.gff > $output/$counts_output

elif [ $COUNTING_TOOL == "nanocount" ]; then
	echo -e " <mop_run> \e[34m counting mapped reads with NanoCount \e[39m"

	counts_output="${name_output/%.*/_nanocount.csv}"

	NanoCount -i $output/$mapped_output -o $tempdir/counts.tsv $COUNT_OPTION
	python bin/tsv_to_csv.py
	mv $tempdir/counts.csv $output/$counts_output

fi

## running bam2stats
echo -e " <mop_run> \e[34m converting bam file with bam2stats \e[39m"

bam2stats_output="${name_output/%.*/_bam2stats.stats}"

python bin/bam2stats.py $output/$mapped_output > $output/$bam2stats_output

## running nanoplot
echo -e " <mop_run> \e[34m plotting bam file with NanoPlot \e[39m"

nanoplot_output="${name_output/%.*/_nanoplot}"

samtools sort $output/$mapped_output -o $tempdir/aligned.bam
NanoPlot --bam $tempdir/aligned.bam $PLOT_OPTION -o $output/$nanoplot_output

## copying output folder to dir and removing tempdir
echo ""
echo -e " <mop_run> \e[33m moving output files to: \e[39m$OUTPUT"
mv $output $OUTPUT

echo -e " <mop_run> \e[33m removing tempdir \e[39m"
rm -r $tempdir
echo ""