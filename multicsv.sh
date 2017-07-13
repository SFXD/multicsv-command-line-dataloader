#!/usr/bin/env bash
########################################################################################################################
########################################################################################################################
###########																								                                                 	############
###########									Salesforce Dataloader										                                       	############
###########							Automated Multi-CSV Command-line utility				                            				############
###########									v. 1 @ Windyo             							                                     		############
###########									Requires Dataloader.sh					                                     						############
###########																								                                                 	### #########
###########																							                                                		############
########################################################################################################################
########################################################################################################################

#Set the variables for the script here.
#Standard bash filtering and variable expansion applies.
FILES=/yourpath/*
OPERATION="UPSERT"
TEMPFILE="./datatoload.csv"
ARCHIVE="/yourpath/"
DATALOADER="./dataloader.sh"
DLPATH=""
DLCONF=""

function sanitycheck
{
    if [ -z "$DLPATH" ]
    then
     	echo 'DLPATH is not set. Please set it in the script, this should normally not vary after first use. This should point to where dataloader-uber.jar is stored, in the format "/home/user/pathtojar"'
     	exit
    else if [ -z "$DLCONF" ]
      	echo 'DLCONF is not set. Please set it in the script, this should normally not vary after first use. This should point to where the config files for the dataloader are stored, in the format "/home/user/pathtoconfig"'
     	exit
     	else
    	massload
    fi
}


function massload
{
#Get the script execution Directory.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

#Change location to the script location for easy referencing on some systems
cd $DIR

#loop over the files found in directory
for f in $FILES
do
  # declare current action
  echo "Processing $f file..."
  # rename current file to allow processing
  mv "$f" "$TEMPFILE"
  # launch dataloader on file
  sh $DATALOADER -a "$OPERATION" "$DLPATH" "$DLCONF" "$TEMPFILE" "$ARCHIVE"
  # move file and archive
  mv "$TEMPFILE" "$ARCHIVE"${f#.csv}"_"$(date +%F)".csv"
done
}

function usage
{
    echo "usage: main.sh [-a (OPERATION /yourpath/to/FILES/* /yourpath/DATALOADER.sh /yourpath/to/ARCHIVE/ (TEMPFILE.csv))] | [-h]]"
}


###ARGUMENTS
while [ "$1" != "" ]; do
    case $1 in
        -a | --automatic )      shift
                                AutomaticMode=1
                                OPERATION=$1
                                FILES=$2
                                DATALOADER=$3
                                ARCHIVE=$4
                                TEMPFILE=$5
                                sanitycheck
                                exit
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     exit 1
    esac
    shift
done

###MAIN
sanitycheck
