#!/bin/sh

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
  
checksum()
{
    md5sum
}

need_to_compute_checksum()
{
  FILE=$1
  FILE_CHECKSUM=$2
  
  trace "  + call need_to_compute_checksum $FILE $FILE_CHECKSUM"

  if [ "$REFRESH" == "0" ]; then
    return 0
  fi

  # if the FILE_CHECKSUM does not exists
  if [ ! -f "$FILE_CHECKSUM" ]; then
    return 0
  else
    LAST_MOD_CHECKSUM=$(stat -c "%y" "$FILE_CHECKSUM")
    trace "  + last_mod_checksum: $LAST_MOD_CHECKSUM"

    # if modify_time greater than modify_time of FILE_CHECKSUM
    LAST_MOD=$(stat -c "%y" "$FILE")
    trace "  + last_mod: $LAST_MOD"
    if [ "$LAST_MOD" \> "$LAST_MOD_CHECKSUM" ]; then
      return 0
    fi

    # if change_time greater than modify_time of FILE_CHECKSUM 
    #   this can occur with some "copy/backup" program that overwrites the file and changes its modify time
    LAST_CHG=$(stat -c "%z" "$FILE")
    trace "  + last_chg: $LAST_CHG"
    if [ "$LAST_CHG" \> "$LAST_MOD_CHECKSUM" ]; then
      return 0
    fi
  fi

  return 1
}

fatal()
{
  if [ "$DEBUG_LEVEL" -ge "1" ] && [ "$SILENT" != "0" ]; then
    echo "FATAL: "$1
    exit 1
  fi
}

error()
{
  if [ "$DEBUG_LEVEL" -ge "2" ] && [ "$SILENT" != "0" ]; then
    echo "ERROR: "$1
  fi
}

warning()
{
  if [ "$DEBUG_LEVEL" -ge "3" ] && [ "$SILENT" != "0" ]; then
    echo "WARN : "$1
  fi
}

info()
{
  if [ "$DEBUG_LEVEL" -ge "4" ] && [ "$SILENT" != "0" ]; then
    echo "INFO : "$1
  fi
}

debug()
{
  if [ "$DEBUG_LEVEL" -ge "5" ] && [ "$SILENT" != "0" ]; then
    echo "DEBUG: "$1
  fi
}

trace()
{
  if [ "$DEBUG_LEVEL" -ge "6" ] && [ "$SILENT" != "0" ]; then
    echo "TRACE: "$1
  fi
}

DEBUG_LEVEL=2
SILENT=1
REFRESH=1
#####################
#### INPUT CHECK ####
#####################
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --debug-level)
    DEBUG_LEVEL="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--refresh)
    REFRESH=0
    shift # past argument
    ;;
    -s|--silent)
    SILENT=0
    shift # past argument
    ;;
    --error)
    DEBUG_LEVEL=2
    shift # past argument
    ;;
    --warning)
    DEBUG_LEVEL=3
    shift # past argument
    ;;
    --info)
    DEBUG_LEVEL=4
    shift # past argument
    ;;
    --debug)
    DEBUG_LEVEL=5
    shift # past argument
    ;;
    --trace)
    DEBUG_LEVEL=6
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

SRC_DIR=$1
DST_DIR=$2

if [ "$SRC_DIR" = "" ]; then
  echo "missing src_dir"
  usage
fi
if [ ! -d "$SRC_DIR" ]; then
  echo "$SRC_DIR is not a directory"
  usage
fi

if [ "$DST_DIR" = "" ]; then
  echo "missing dst_dir"
  usage
fi
if [ ! -d "$DST_DIR" ]; then
  echo "$DST_DIR is not a directory"
  usage
fi

CHECKSUM=md5sum


#####################
####   COMPARE   ####
#####################

# list all files of src_dir and dst_dir
SRC_FILES=$(find $SRC_DIR/* | awk -F $SRC_DIR ' { print $NF } ' )
#DST_FILES=$(find $DST_DIR/*)

MISSING_FILES=0
DIFFERENT_FILES=0
ERRORS=0

# foreach SRC_FILE, compute the checksum of the file in src_dir and dst_dir
while read -r RELATIVE_PATH; do

  #if RELATIVE_PATH ends with the checksum name, skip it
  if [ "$(echo $RELATIVE_PATH | tail -c 7)" = "$CHECKSUM" ]; then
    continue
  fi

  info "computing file \"$RELATIVE_PATH\""


  SRC_FILE=$SRC_DIR/$RELATIVE_PATH
  DST_FILE=$DST_DIR/$RELATIVE_PATH
  SRC_FILE_CHECKSUM=$SRC_FILE.$CHECKSUM
  DST_FILE_CHECKSUM=$DST_FILE.$CHECKSUM

  SRC_FILE_CLEAN=$(printf '%q' "$SRC_FILE")
  DST_FILE_CLEAN=$(printf '%q' "$DST_FILE")
  SRC_FILE_CHECKSUM_CLEAN=$(printf '%q' "$SRC_FILE_CHECKSUM")
  DST_FILE_CHECKSUM_CLEAN=$(printf '%q' "$DST_FILE_CHECKSUM")


  # check SRC_FILE is a valid file
  if [ -f "$SRC_FILE" ]; then

    # check if DST_FILE exists
    if [ -f "$DST_FILE" ]; then

      # compute the checksum of SRC_FILE, if needed  
      if need_to_compute_checksum "$SRC_FILE" "$SRC_FILE_CHECKSUM"; then
        CMD="$CHECKSUM $SRC_FILE_CLEAN | cut -c 1-32 > $SRC_FILE_CHECKSUM_CLEAN"
        debug "computing checksum for $SRC_FILE"
        eval $CMD
        if [ $? != "0" ]; then
          let ERRORS++
          error "  - failed computing CHECKSUM for $SRC_FILE"
          continue
        fi
      fi

      # compute the checksum of DST_FILE, if needed
      if need_to_compute_checksum "$DST_FILE" "$DST_FILE_CHECKSUM"; then
        CMD="$CHECKSUM $DST_FILE_CLEAN | cut -c 1-32 > $DST_FILE_CHECKSUM_CLEAN"
        debug "computing checksum for $DST_FILE"
        eval $CMD
        if [ $? != "0" ]; then
          let ERRORS++
          error "  - failed computing CHECKSUM for $DST_FILE"
          continue
        fi
      fi


      # compare the checksums (if different, increment different_files counter and output the name of the different file)
      cmp -s "$SRC_FILE_CHECKSUM" "$DST_FILE_CHECKSUM"
      if [ $? != "0" ]; then
        let DIFFERENT_FILES++
        error "  - different files: $SRC_FILE != $DST_FILE"
        continue
      fi

    # else increment the missing_files and output the name of missing file
    else
      let MISSING_FILES++
      error "  - missing file: $DST_FILE"
    fi
  fi
done <<< "$SRC_FILES"

# output a report of
# * missing files in dst_dir
# * different files
# * errors

if [ "$SILENT" != "0" ]; then
  echo ""
  echo ""
  echo "MISSING_FILES: $MISSING_FILES"
  echo "DIFFERENT_FILES: $DIFFERENT_FILES"
  echo "ERRORS: $ERRORS"
fi

# exit 0 if the 2 directories are equal
if [ "$MISSING_FILES" = "0" ]; then
  if [ "$DIFFERENT_FILES" = "0" ]; then
    if [ "$ERRORS" = "0" ]; then
      exit 0
    fi
  fi
fi

exit 1