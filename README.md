**ONT-RNA-Sequencing**

_Made by mop and honhon_

Long-read genome sequencing is being used more and more in the past decade. With it, the need for consistent data analysing tools has increased. However, the knowledge needed to correctly use these tools has increased at the same pace. This hinders general access and use-cases for the technique. Therefore, we present our workflow.

The produced workflow includes all steps needed to do the preprocessing of FASTQ files produced by Nanopore direct RNA sequencing for later downstream processing except for quality control of the raw and trimmed data. It allows users a choice of different tools with an option to change their settings manually or use the basic settings. This makes it easier for the general user to analyze Nanopore direct RNA-seq data. 

For the future, it is planned to implement automated DESEq2 analysis in the workflow and the NanoTail and NanoMod modules from the original Masters of Pores workflow, as well as adding new ease of use options and converting the wrapper to a more convenient language like Nextflow. Further testing with the current and new datasets should also be performed to remove any kinks that are still present and to better test Graphmap2 and HTSeq-count. This all to make an easy to use RNA-seq analysis tool.

****

**Usage:**
 Bash mop_workflow.sh [-h] [-o <file>] [-i <file>] [-r <file>] [-a file]
	
	[-m minimap2 | graphmap2] [-c nanocount | htseqcount] [-d yes | no] [-t yes | no] [-n yes | no]
	
	[-z "N"] [-y "N"] [-x "N"] [-w "N"]

 General options:
  
	-h		show the help and exit.
	-o		Specify directory name in which ouput is copied. (workflow will create the output directory)

 Input data:
	
	-i		path to fastq.gz file.
	-r		path to reference.gz file.
	-a		path to gff.gz file.

 Tool and module selections:
  
	-m		Specify mapping tool that will be used. (minimap2 or graphmap2)
	-c		Specify counting tool. (nanocount or htseqcount)
	-d		Specify if DESeq2 should be run. (yes or no)
	-t		Specify if NanoTail should be run. (yes or no)
	-n		Specify if NanoMod should be run. (yes or no)

 Seperate tool options:
  
	-z "N"		Specify specific tool options between " ", for NanoFilt filter tool. (for usage check tool's github at: https://github.com/wdecoster/nanofilt)
	-y "N"		Specify specific tool options between " ", for selected mapping tool. (for usage check tool's github at: https://github.com/lh3/minimap2 or https://github.com/lbcb-sci/graphmap2)
	-x "N"		Specify specific tool options between " ", for selected counting tool. (for usage check tool's github at: https://github.com/a-slide/NanoCount or https://github.com/htseq/htseq)
	-w "N"		Specify specific tool options between " ", for NanoPlot plotting tool. (for usage check tool's github at: https://github.com/wdecoster/NanoPlot)
