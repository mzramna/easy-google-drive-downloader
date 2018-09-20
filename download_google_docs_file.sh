#!/bin/bash
echo "insert the google service name (in english) to download (if you write it wrong the code will not work)";
read GOOGLE_SERVICE;
echo "insert the google $GOOGLE_SERVICE ID to download";
read FILEID;
FILENAME="$(wget --quiet -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
echo "insert the google $GOOGLE_SERVICE EXTENSION to download(if you insert a wrong or not suportated file extension it may not work)";
read FILEEXTENSION;
wget -c "https://docs.google.com/$GOOGLE_SERVICE/export?format=$FILEEXTENSION&id=$FILEID&includes_info_params=true" -O "$FILENAME.$FILEEXTENSION"
