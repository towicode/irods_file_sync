#!/bin/bash

# $1 = local path including file name (/local/path/to/filename.txt)
# $2 = full remote path including file name (/iplant/home/user/path/to/file/filename.txt)
if [ -z "$1" ]
  then
    echo "USAGE:"
    echo ""
    echo "stage_to_cyverse /local/path/to/filename.txt /iplant/home/user/path/to/file/filename.txt"
    exit 1
fi

if [ -z "$2" ]
  then
    echo "USAGE:"
    echo ""
    echo "stage_to_cyverse /local/path/to/filename.txt /iplant/home/user/path/to/file/filename.txt"
    exit 1
fi


# declare the locations of these executables and directories
IPUT=/usr/bin/iput
IRSYNC=/usr/bin/irsync
TMP_LOCATION=${HOME}/cyverse_tmp/staging
LOG_LOCATION=${HOME}/cyverse_tmp/logs


# Just tests to ensure that the following commands are installed
# Basically checking if IRODS is installed
test_exists_executable() {
    file=$FILE
    if [[ -x "$file" ]]
    then
        :
    else
        echo "ERROR:"
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

FILE=/usr/bin/dirname
test_exists_executable

FILE=$IPUT
test_exists_executable

FILE=$IRSYNC
test_exists_executable

# determine the date
tmp_d=`/bin/date +"%Y_%m_%d"`

# determine log and create directory
LOG=${LOG_LOCATION}/$0-${tmp_d}.log
/bin/mkdir -p $LOG_LOCATION


if [ ! -f $1 ]; then
    echo "ERROR:"
    echo "File not found!"
    exit 1
fi

# attempt a file transfer
echo `/bin/date`" attempting transfer of $1 to $2" >>$LOG
$IPUT -f -V $1 $2 >>$LOG 2>&1
if [ $? != 0 ]; then

	# at this point failure	
	echo `/bin/date`" failed transfer" >>$LOG

	# first create the path locally
    tmp_path=`/usr/bin/dirname $2`

    # create directory
    full_path=$TMP_LOCATION/${tmp_d}${tmp_path}
    /bin/mkdir -p ${full_path} >>$LOG 2>&1

    # copy file
	echo `/bin/date`" full path to file is ${full_path}, attempting copy" >>$LOG
    /bin/mv $1 ${full_path} >>$LOG 2>&1
fi