#!/bin/sh

## Log level
##  - 0 => FATAL
##  - 1 => ERROR
##  - 2 => WARNING
##  - 3 => INFO
##  - 4 => DEBUG
##  - 5 => TRACE
FATAL=0
ERROR=1
WARNING=2
INFO=3
DEBUG=4
TRACE=5

## Print the help messages
usage()
{
    echo "USAGE: $0 [options] <src_dir> <dst_dir>"
    echo ""
    echo "options:"
    echo "  -s | --silent: don't print anything"
    echo "  -r | --refresh: ignore already computed local checksums"
    echo "  --error: [default] print only errors found. ex: missing files, different files"
    echo "  --info: print information about the computed files"
    echo "  --debug: print debug information"
    echo "  --trace: print all the possible information"
    echo ""
    echo "$0 compares src and dst directories performing checksums of all the files"
    echo "It can be interrupted at any time and restarted later"
    echo "exit value:"
    echo "  0: the 2 directories contains the same files"
    echo "  not 0: the 2 directories have at least one difference or an error occurred"
    exit 1
}

## This function allow to print out the log messages according to the configuration
##   INPUT:
##       - TYPE: $FATAL, $ERROR, $WARNING, $DEBUG, $INFO
##       - MESSAGE: string to print
log() 
{

    type=$1
    msg=$2

    if [ "$SILENT" -eq "0" ]; then return 0; fi             ## if silent is enabled => finish
    if [ "$DEBUG_LEVEL" -lt "$type" ]; then return 1; fi    ## if DEBUG_LEVEL is under the necessary to print the message => finish

    case $type in
        $FATAL)
            echo "FATAL: "$msg;
            ;;
        $ERROR)
            echo "ERROR: "$msg;
            ;;
        $WARNING)
            echo "WARN: "$msg;
            ;;
        $INFO)
            echo "INFO: "$msg;
            ;;
        $DEBUG)
            echo "DEBUG: "$msg;
            ;;
        $TRACE)
            echo "TRACE: "$msg;
            ;;
    esac

    if [ "$type" -le "$FATAL" ]; then exit 1; fi ## exit on blocking problems
}

########################## SHORTCUT PRINT MESSAGE ########################

fatal(){ log $FATAL $1; }
error(){ log $ERROR $1; }
warning(){ log $WARNING $1; }
info(){ log $INFO $1; }
debug(){ log $DEBUG $1; }
trace(){ log $TRACE $1; }