#!/bin/bash

# assign inputs
while getopts hi:r:o:m:c:a:d:t:n:z:y:x:w: option
do
case "${option}"
in

#help
h) HELP=${OPTARG};;

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
t) TAIL=${OPTARG};;
n) NANOMOD=${OPTARG};;

# tool options
z) FILT_OPTION=${OPTARG};;
y) MAPPING_OPTION=${OPTARG};;
x) COUNT_OPTION=${OPTARG};;
w) PLOT_OPTION=${OPTARG};;

esac
done

# check help
echo ""
if [ $1 == "-h" ]; then
	cat bin/mop_usage.txt
	echo ""
	exit 1
fi

# check inputs
echo -e " <mop_workflow> \e[34m **checking input arguments** \e[39m"
echo ""
echo -e " <mop_input> \e[33m checking if necessary arguments are given \e[39m"

if [ -z "$OUTPUT" ]; then
        echo " <mop_input>  -o (output path) not given"
        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi

if [ -z "$INPUT_SEQ" ]; then
        echo " <mop_input>  -i (input sequence) not given"
        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi

if [ -z "$REF_SEQ" ]; then
	echo " <mop_input>  -r (reference sequence) not given"
        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi

echo -e " <mop_input> \e[32m necessary arguments given \e[39m"

# check if output already exists
echo ""
echo -e " <mop_input> \e[33m checking version ID \e[39m"

if test -d $OUTPUT; then
	echo -e " <mop_input> \e[31m ERROR $OUTPUT already exists! \e[39m"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

else
	echo -e " <mop_input> \e[32m $OUTPUT does not exist \e[39m"
	echo ""
fi

## check if input_seq exists
echo -e " <mop_input> \e[33m checking for input sequence \e[39m"

if test -f $INPUT_SEQ; then
        echo -e " <mop_input> \e[32m $INPUT_SEQ found \e[39m"
	echo ""

else
        echo -e " <mop_input> \e[31m ERROR $INPUT_SEQ not found! \e[39m"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1
fi

## check if ref_seq exists
echo -e " <mop_input> \e[33m checking for reference sequence \e[39m"

if test -f $REF_SEQ; then
        echo -e " <mop_input> \e[32m $REF_SEQ found \e[39m"
	echo ""

else
        echo -e " <mop_input> \e[31m ERROR $REF_SEQ not found! \e[39m"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1
fi

## checking optional arguments
echo -e " <mop_input> \e[33m checking optional arguments \e[39m"

# mapping tool
if [ -z "$MAPPING_TOOL" ]; then
	MAPPING_TOOL="minimap2"
	# mapping option
	if [ -z "$MAPPING_OPTION" ]; then
        	MAPPING_OPTION="-t 4 -ax map-ont -p 0 -N 10"
	fi

elif [ $MAPPING_TOOL == graphmap2 ]; then
        MAPPINT_TOOL="graphmap2"
	# mapping option
	if [ -z "$MAPPING_OPTION" ]; then
        	MAPPING_OPTION="-x rnaseq"	
	fi

elif [ $MAPPING_TOOL == minimap2 ]; then
	MAPPING_TOOL="minimap2"
	# mapping option
	if [ -z "$MAPPING_OPTION" ]; then
        	MAPPING_OPTION="-t 4 -ax map-ont -p 0 -N 10"
	fi

else
        echo -e " <mop_input> \e[31m ERROR mapping tool \e[39m($MAPPING_TOOL)\e[31m not valid! \e[39m :can either be graphmap2 (default) or minimap2"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi
echo -e " <mop_input> \e[32m mapping tool valid \e[39m"

# counting tool
if [ -z "$COUNTING_TOOL" ]; then
        COUNTING_TOOL="nanocount"
	ANNOTATION="fake_news"
	# counting option
	if [ -z "$COUNT_OPTION" ]; then
        	COUNT_OPTION=""	
	fi

elif [ $COUNTING_TOOL == htseqcount ]; then
        COUNTING_TOOL="htseqcount"

	if [ -z "$COUNT_OPTION" ]; then
        	COUNT_OPTION="--type contig --idattr ID --stranded no -a 0"	
	fi

	## check if annotaion is given
	if [ -z "$ANNOTATION" ]; then
		echo " <mop_input>  -a (annotation) not given"
        	echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        	exit 1

	fi

	## check if annotation exists
	echo -e " <mop_input> \e[33m checking for annotation \e[39m"

	if test -f $ANNOTATION; then
        	echo -e " <mop_input> \e[32m $ANNOTATION found \e[39m"
		echo ""

	else
        	echo -e " <mop_input> \e[31m ERROR $ANNOTATION not found! \e[39m"

        	echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        	exit 1
	fi

elif [ $COUNTING_TOOL == nanocount ]; then
        COUNTING_TOOL="nanocount"
	ANNOTATION="fake_news"

else
        echo -e " <mop_input> \e[31m ERROR counting tool \e[39m($COUNTING_TOOL)\e[31m not valid! \e[39m :can either be nanocount (default) or htseqcount"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi
echo -e " <mop_input> \e[32m counting tool valid \e[39m"

# deseq2
if [ -z "$DESEQ" ]; then
        DESEQ="no"

elif [ $DESEQ == yes ]; then
        DESEQ="yes"

elif [ $DESEQ == no ]; then
        DESEQ="no"


else
        echo -e " <mop_input> \e[31m ERROR DESeq2 option \e[39m($DESEQ)\e[31m not valid! \e[37m :can either be no (default) or yes \e[39m"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi
echo -e " <mop_input> \e[32m deseq option valid \e[39m"

# NanoTail
if [ -z "$TAIL" ]; then
        TAIL="no"

elif [ $TAIL == yes ]; then
        TAIL="yes"

elif [ $TAIL == no ]; then
        TAIL="no"


else
        echo -e " <mop_input> \e[31m ERROR NanoTail option \e[39m($TAIL)\e[31m not valid! \e[37m :can either be no (default) or yes \e[39m"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi
echo -e " <mop_input> \e[32m NanoTail option valid \e[39m"

# NanoMod
if [ -z "$NANOMOD" ]; then
        NANOMOD="no"

elif [ $NANOMOD == yes ]; then
        NANOMOD="yes"

elif [ $NANOMOD == no ]; then
        NANOMOD="no"


else
        echo -e " <mop_input> \e[31m ERROR NanoMod option \e[39m($NANOMOD)\e[31m not valid! \e[37m :can either be no (default) or yes \e[39m"

        echo -e " <mop_input> \e[31m EXITING WORKFLOW! \e[39m"
        exit 1

fi
echo -e " <mop_input> \e[32m NanoMod option valid \e[39m"
echo ""

## checking tool options
echo -e " <mop_input> \e[33m checking tool arguments \e[39m"

# filter option
if [ -z "$FILT_OPTION" ]; then
        FILT_OPTION="-q 0 --headcrop 5 --tailcrop 3"
fi

# mapping option
#if [ -z "$MAPPING_OPTION" ]; then
#        MAPPING_OPTION="-x rnaseq"	
#fi

# counting option
#if [ -z "$COUNT_OPTION" ]; then
#        COUNT_OPTION=""	
#fi

# nanoplot option
if [ -z "$PLOT_OPTION" ]; then
        PLOT_OPTION=""	
fi

echo -e " <mop_input> \e[32m tool arguments checked \e[39m"
echo""

echo -e " <mop_workflow> \e[34m **showing parameters** \e[39m"
echo ""
bash bin/mop_parameters.sh -i $INPUT_SEQ -r $REF_SEQ -o $OUTPUT -m $MAPPING_TOOL -c $COUNTING_TOOL -a $ANNOTATION -d $DESEQ -t $TAIL -n $NANOMOD -z "$FILT_OPTION" -y "$MAPPING_OPTION" -x "$COUNT_OPTION" -w "$PLOT_OPTION"

##(activate conda env)##
echo -e " <mop_workflow> \e[34m **running workflow** \e[39m"
echo ""
bash bin/mop_run.sh -i $INPUT_SEQ -r $REF_SEQ -o $OUTPUT -m $MAPPING_TOOL -c $COUNTING_TOOL -a $ANNOTATION -d $DESEQ -t $TAIL -n $NANOMOD -z "$FILT_OPTION" -y "$MAPPING_OPTION" -x "$COUNT_OPTION" -w "$PLOT_OPTION"
##(deactivate conda env)##

echo -e " <mop_workflow> \e[34m **process finished** \e[39m"
echo ""