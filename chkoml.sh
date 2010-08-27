#!/bin/sh
# @(#)chkoml		Version  1.20	 8/27/10 

usage()         # function 'usage' echoes the syntax
{
    echo "\nUsage:  $PROG  -aodxvh\n"
    echo "        -a: display all OM lists"
    echo "        -o: display orphaned lists"
    echo "        -d: delete CAD-related orphaned lists"
    echo "        -x: delete all orphaned lists"
    echo "        -v: verbose mode, used with -d and -x"
    echo "        -h: show this help prompt\n"
}

PROG=`basename $0`
if [ $# -eq 0 ]; then usage; exit; fi

#
# uncomment and edit the following line to point to where close_list 
# is installed
#CLOSEOM=/path/to/close_list

# set up some useful variables for use later
SOM=/opt/fox/bin/tools/som
INPUT_FILE=/tmp/$$input.txt
OUTPUT_FILE=/tmp/$$output.txt
CLEAN_FILE=/tmp/$$clean.txt

#
# make sure we can use the common tools
PATH=/bin:/usr/bin/:usr/sbin
export PATH

#
# parse the command line for parameters using getopts
while getopts aodxvh opt
do
    case $opt in
        a)    SH_ALLOM=true;;
        o)    SH_ORPHAN=true;;
        d)    DEL_CAD=true;;
        x)    DEL_ALL=true;;
        v)    VERBOSE=true;;
        h)    usage; exit;;
    esac
done
shift `expr $OPTIND - 1`

#
# generate the input file
echo "opdb\nf" > $INPUT_FILE
i=0
while [ $i -lt 20 ]; do
    echo "m opdb\nf" >> $INPUT_FILE
    i=`expr $i + 1`
done
echo "q" >> $INPUT_FILE

#
# use som to get all of the local lists
$SOM -i $INPUT_FILE -t $OUTPUT_FILE > /dev/null
grep Local $OUTPUT_FILE | sort -u > $CLEAN_FILE

#
# display all open OM lists
if [ "$SH_ALLOM" = "true" ]; then cat $CLEAN_FILE; fi

#
# look for orphaned OM lists if they specify -o and/or -d/-x
if [ "$SH_ORPHAN" = "true" -o "$DEL_CAD" = "true" -o "$DEL_ALL" = "true" ]
then
    #
    # loop through all open lists to get the PIDs
    for pid in `nawk '{print $6}' $CLEAN_FILE | sort -u`
    do
        #
        # see if the process that opened the list is still active
        ps -p $pid > /dev/null
        if [ $? != 0 ]
        then
            #
            # find all open lists associated with the dead process
            if [ "$SH_ORPHAN" = "true" ]
            then
                nawk '$6 ~ PID \
                     {print $6 "   " $1 "   " $5 "   " $7}' PID=$pid $CLEAN_FILE
            fi
            #
            # delete the list(s) associated with this PID if it ...
            # (1) is unoptimized, and (2) has a size of 2
            if [ "$DEL_CAD" = "true" ]
            then
                for listid in `nawk '$6 ~ PID && $5 ~ /N/ && $7 ~ 002 \
                    {printf("%.0f\n",$1)}' PID=$pid $CLEAN_FILE`
                do
                    $CLOSEOM $listid
                    if [ "$VERBOSE" = "true" ]
                    then echo "List $listid (PID=$pid) closed"
                    fi
                done
            fi
            #
            # delete the list(s) associated with this PID if they
            # specified option -x
            if [ "$DEL_ALL" = "true" ]
            then
                for listid in `nawk '$6 ~ PID \
                    {printf("%.0f\n",$1)}' PID=$pid $CLEAN_FILE`
                do
                    $CLOSEOM $listid
                    if [ "$VERBOSE" = "true" ]
                    then echo "List $listid (PID=$pid) closed"
                    fi
                done
            fi
        fi
    done
fi

#
# clean up
rm $INPUT_FILE $OUTPUT_FILE $CLEAN_FILE 2> /dev/null
