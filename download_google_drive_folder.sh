#!/bin/bash
echo "insert the google drive folder full url to download";
read FILEID;
FOLDERID="$(echo $FOLDERID | sed -n 's#.*\https\:\/\/drive\.google\.com/drive/folders/\([^.]*\)\/view.*#\1#;p')";
FOLDERNAME="$(wget -q --show-progress -O - "https://drive.google.com/drive/folders/$FOLDERID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
#get folder content using: https://yasirkula.net/drive/downloadlinkgenerator/?state=%7B"ids":%5B"$FOLDERID"%5D,"action":"open","userId":""7D
#the files are listed in <pre id="result">
#pattern is: line with the file and relative path; line with href to download the file
#the href is with the direct download link,to get the id to download file use the RE: "sed -n 's#.*\https\:\/\/drive\.google\.com\/uc\?id=\([^.]*\)\&export\=download.*#\1#;p')"
#the result of this RE is used into download_google_drive_file.sh as parameter
#wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget -q --show-progress --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$FILEID" -c -O $FILENAME && rm -rf /tmp/cookies.txt;
#echo "file $FILENAME has been downloaded"
