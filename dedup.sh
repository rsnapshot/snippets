#!/bin/sh
# 
# This searches for duplicate files run by the backup_script of rsnapshot.
#
# This is ideal for scripts that generate rougly the same output each time
# and where you want to conserve disk space.
#
#
# Dependencies:
#
# find, cmp, rm and ln all in the path.
#
#
# Usage:
#
# dedup.sh {referencedir}
#
# referencedir is the directory in ../../${referencedir} where the same set of
# files may exist for comparision
#
# in rsnapshot.conf
#
# backup_script	{some backup script that generates files} && dedup.sh	dir/
#
# If you are doing hourly backups dedup.sh takes an argument of the reference point
#
# backup_script	{some backup script that generates files} && dedup.sh hourly.1	dir/
#
#
# Example:
#
# backup_script	/usr/bin/mydumper -u backup --threads 8 --rows 30000 --compress --outputdir mydumper --logfile mydumper.log && /usr/local/bin/dedup.sh	dbdump/
#
# Design Assumptions:
#
# * This is run from the temporary directory where rsnapshot.
# * rotations occur before the backup_script is run
# * this assumes that ln will succeed. There are ln options for backup that might remove this assumption


PREV=${1:-daily.1}
DIR=${PWD##*/}

find . -type f -print0 | while read -d $'\0' file;
do
    prevfile="../../${PREV}/${DIR}/${file}"
    cmp -s "${file}" "${prevfile}" && rm "${file}" && ln "${prevfile}" "${file}"
done
