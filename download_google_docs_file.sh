#!/bin/bash
echo "insert the google doc url";
read FILEURL;
GOOGLE_SERVICEFILEID="$(echo $FILEURL | sed -n 's#.*\https\:\/\/docs\.google\.com\/\([^.]*\)\/d\/*.*#\1#;p')";
FILEID="$(echo $FILEURL | sed -n "s#.*\https\:\/\/docs\.google\.com\/$GOOGLE_SERVICEFILEID\/d\/\([^.]*\)\/.*#\1#;p")";
FILENAME="$(wget --quiet -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
echo "insert the google $GOOGLE_SERVICE EXTENSION to download(if you insert a wrong or not suportated file extension it may not work)";
read FILEEXTENSION;
wget -c "https://docs.google.com/$GOOGLE_SERVICEexport?format=$FILEEXTENSION&id=$FILEID&includes_info_params=true" -O "$FILENAME.$FILEEXTENSION"
