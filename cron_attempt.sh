#!/bin/bash

# ensure local directory is created $HOME/cyverse_tmp/completed
# foreach directory found in $HOME/cyverse_tmp/staging/ (they should be named by date)
# irsync the folder
# if status successful, move to $HOME/cyverse_tmp/completed/

# declare the locations of these executables and directories
IRSYNC=/usr/bin/irsync
FIND=/usr/bin/find
# DTL is the location of where you want the files on your IRODS server
DELAYED_TRANSFER_LOCATION=delayed_transfers
DTL=$DELAYED_TRANSFER_LOCATION


DONE_LOCATION=${HOME}/cyverse_tmp/completed
LOG_LOCATION=${HOME}/cyverse_tmp/logs
TMP_LOCATION=${HOME}/cyverse_tmp/staging

# Just tests to ensure that the following commands are installed
# Basically checking if IRODS is installed
test_exists_executable() {
    file=$FILE
    if [[ -x "$file" ]]
    then
        :
    else
        echo "File '$file' is not executable or found"
        exit 1
    fi
}


FILE=/bin/date
test_exists_executable

FILE=/bin/mkdir
test_exists_executable

FILE=/bin/mv
test_exists_executable

FILE=$FIND
test_exists_executable

FILE=$IRSYNC
test_exists_executable

# determine the date
tmp_d=`/bin/date +"%Y_%m_%d"`

# determine log and create directory
LOG=${LOG_LOCATION}/$0-${tmp_d}.log

#/bin/mkdir $TMP_LOCATION/tmp
# ensure the completed directory exists
/bin/mkdir -p $DONE_LOCATION >>$LOG 2>&1


# there is a weird bug with bash where if the directory is 
# empty it still returns a non existant path in the loop below
# this check just efficently checks to see if there is 
# any existing folder in /staging
target=$TMP_LOCATION
if $FIND "$target" -mindepth 1 -print -quit | grep -q .; then
    :
else
    echo -e `/bin/date`" Nothing to transfer\n" >>$LOG
    exit 0
fi


#   Since folder is not empty we loop through folders in the folder
#   And transfer the file using rysync
for d in $TMP_LOCATION/?*/ ; do
    #echo $d
    $IRSYNC -r $d i:$DTL

    # if sucessful then 
    if [ $? == 0 ]; then
        echo -e `/bin/date`" Transfer of $d sucessful, moving to completed \n" >>$LOG
        /bin/mv $d $DONE_LOCATION 
    fi
done


