#!/bin/sh

##################### config parameters ###################
DEBUG_LEVEL=2
SILENT=1
REFRESH=1
CHECKSUM="md5sum"
#CHECKSUM="md5 -r" ## fix for mac 

######################### variables #######################
MISSING_FILES=0
DIFFERENT_FILES=0
ERRORS=0