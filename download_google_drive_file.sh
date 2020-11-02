#!/bin/bash
checkurl() {
	FILEID=$1
	if echo $FILEID | sed -n 's#.*\https\:\/\/drive\.google\.com/file/d/\([^.]*\)\/view.*#\1#;p' | wc -l; then
		echo "url valida"
		return 1
	else
		echo "Please input 'https://drive.google.com/file/d/xxxxxxx/view'"
		return 0
	fi
}
check_quota(){
	FILENAME=$1
	if grep -q "Quota exceeded" "$FILENAME"; then
		rm $FILENAME && \
		echo "Google Drive Limited (Quota Exceeded)" && \
		echo "file $FILENAME can NOT be downloaded"
		return 0
	else
		echo "file $FILENAME has been downloaded"
		return 1
	fi

}
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
if [ -f "$FILENAME" ]; then
	echo "file $FILENAME has been downloaded"
else
	echo "file $FILENAME cannot be downloaded,any error appear"
fi
