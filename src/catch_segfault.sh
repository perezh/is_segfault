#! /bin/bash
# Script_name     : catch_segfault.sh
# Author          : Intro_SW
# Description     : Print backtrace of sigfault
# Prerequisites   : catchsegv, file (v5.30), addr2line, timeout, tac
#                   sudo apt-get install glibc-tools
# Version         : v1.0

: ${1?"Usage: $0 EXECUTABLE_WITH_DEBUG_SYMBOLS"}
#  Script exits here if command- parameter absent
#set -x                     # Enable debug in bash

PROGRAM="$1"                # Name of the binary
NUM_SRC_CONTEXT_S=3         # Number of lines of source code in the output
DIR=$(pwd)

function show_backtrace_content {
    TEXT="$1"     # test to parse
    old_IFS=$IFS  # save the field separator
    IFS=$'\n'     # new field separator

    prefix="|-"   # prefix for printing the call stack
    filter=true   # filter first functions

    echo "* Getting call stack (format ==> function:line (file))"
    for LINE in $TEXT; do
       IFS=$old_IFS     # restore default field separator
       # get params within markers ()[]
       EXEC=$(echo $LINE | cut -d'(' -f1)
       OFFS=$(echo $LINE | cut -d'(' -f2 | cut -d')' -f1)
       ADDR=$(echo $LINE | cut -d'[' -f2 | cut -d']' -f1)
       A2L=$(addr2line -a -s -e $EXEC -pfC $OFFS)
       #echo "BACKTRACE:  $EXEC $ADDR $OFFS"
       #echo "A2L:        $A2L"

       FUNCTION=$(echo $A2L | sed 's/\<at\>.*//' | cut -d' ' -f2-99)
       FILE_AND_=$(echo $A2L | sed 's/.* at //')
       SRCFILE=$(echo $FILE_AND_ | cut -d':' -f1)
       NUM=$(echo $FILE_AND_ | cut -d':' -f2)
       #echo "FILE:       $FILE_AND_"
       #echo "FUNCTION:   $FUNCTION"

       # Print info starting from main function
       if [[ "$FUNCTION" == *"main"* ]]; then
            filter=false
       fi

       if [ "$filter" == false ]; then
        printf "%s %s:%s  (%s)" $prefix $FUNCTION $NUM $SRCFILE
        printf '\n'
        prefix="$prefix--" # Update prefix
       fi
       IFS=$'\n'          # new field separator
    done

    printf '\n\n'

    # print 'segmentation fault' source code for last backtrace
    printf "* Printing the source code which may cause the segmentation fault (* shows the target line)\n"
    if ([ -f $SRCFILE ]); then
        cat -n $SRCFILE | grep -C $NUM_SRC_CONTEXT_S "^ *$NUM\>" | sed "s/ $NUM/*$NUM/"
    else
        echo "File not found: $SRCFILE"
    fi

    IFS=$old_IFS     # restore default field separator
}

# Error handling
# Check for English output - This is a bit tricky as English can be set using
# different locales so a wrapper is created (is_segfault) to set LC_ALL=C to show english
# messages for the output
source <(locale)
if [ ! "$LC_ALL" = "C" ]; then
    printf "The locale for output messages is not in English.\n"
    printf "This tool only supports parsing english output.\n"
    printf "Try execute the tool as follows: LC_ALL=C $0 EXECUTABLE_WITH_DEBUG_SYMBOLS\n"
    exit 1
fi
# Check for input file
if [ ! -f "$PROGRAM" ]; then
    echo "The file $PROGRAM does not exist."
    printf "First argument should be an executable file with debug symbols that produces a segmentation fault\n"
    printf "Usage: $0 EXECUTABLE_WITH_DEBUG_SYMBOLS\n"
    exit 1
fi
# Check for debug symbols
if !(file "$PROGRAM" | grep -q "with debug_info") ; then
    printf "\nError: Executable should be generated with debug options (e.g., -g for gcc)\n"
    printf "Compile with debug options and run the tool again\n"
    exit 1
fi

printf "\nRunning ${PROGRAM} and waiting for a segmentation fault..."
printf "\nPlease note that applications waiting for I/O operations before \nsegmentation fault are NOT supported yet (e.g., using scanf or get_user_int)\n\n"

# Assume SIGSEGV has exit code of 139, quiet segmentation fault message
{ timeout 4 ${DIR}/${PROGRAM}; } &> /dev/null
if [[ !($? -eq 139) ]]; then
    printf "\nError: Segmentation fault not found. "
    printf "\nExecutable should raise a segmentation fault to run this tool!\n"
    printf "\nPlease note that applications waiting for I/O operations before \nsegmentation fault are NOT supported yet (e.g., using scanf or get_user_int)\n\n"
    exit 1
fi

# Get backtrace content (between Backtrace: and Memory map: markers)
MARKER1="Backtrace:"
MARKER2="Memory map:"
BACKTRACE=$(catchsegv ${DIR}/${PROGRAM} | sed -n "/${MARKER1}/,/${MARKER2}/{/${MARKER1}/d;/${MARKER2}/d; p }")

# Parse content
CONTENT=$(echo "${BACKTRACE}" | tac) # FIFO order
echo ""
show_backtrace_content "${CONTENT}"

echo ""
