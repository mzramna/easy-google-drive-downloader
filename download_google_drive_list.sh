#!/bin/bash
filename='gdrive_links.txt'
echo Start
#
#pidlist=()
while read p; do 

	./download_google_drive_file.sh $p #& # if uncomment the "&" it will download all the files at the same time,it can crash if had lots of files
  #if download an really big amount of downloads(more than 10 could do it) google drive will notice that it is an algorithim and will reduce the speed and maby block your ip to download(sometimes it gives exceded amount of downloads into the files)
#	pidlist=("$pidlist[@]" $!)# $! = pid from process
done < $filename

