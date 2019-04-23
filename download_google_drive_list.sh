#!/bin/bash
filename='gdrive_links.txt'
echo Start
#
#pidlist=()

function download_file {
if [ $# -eq 1 ];then
        FILEID=$1
else
        echo "insert the google drive full url to download";
        read FILEID;
fi
FILEID="$(echo $FILEID | sed -n 's#.*\https\:\/\/drive\.google\.com/file/d/\([^.]*\)\/view.*#\1#;p')";
FILENAME="$(wget -q --show-progress -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
CONFIRM_CODE=$(wget -q --show-progress --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM_CODE&id=$FILEID" -c -O "$FILENAME" && rm -rf /tmp/cookies.txt;
echo "file $FILENAME has been downloaded"

}

while read p; do 

	download_file $p #& # if uncomment the "&" it will download all the files at the same time,it can crash if had lots of files
  #if download an really big amount of downloads(more than 10 could do it) google drive will notice that it is an algorithim and will reduce the speed and maby block your ip to download(sometimes it gives exceded amount of downloads into the files)
#	pidlist=("$pidlist[@]" $!)# $! = pid from process
done < $filename

