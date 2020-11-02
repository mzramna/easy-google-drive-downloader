#!/bin/bash
function dr_file_select(){
    local TITLE=${1:-$MSG_INFO_TITLE}
    local LOCAL_PATH=${2:-$(pwd)}
    local FILE_MASK=${3:-"*"}
    local ALLOW_BACK=${4:-no}
    local FILES=()

    #[ "$ALLOW_BACK" != "no" ] && FILES+=(".." "..")

    # First add folders
    # shellcheck disable=SC2044
    # shellcheck disable=SC2086
    # shellcheck disable=SC2044
    
    for DIR in $(find "$LOCAL_PATH" -maxdepth 1 -mindepth 1 -type d -printf "%f " 2> /dev/null)
    do
        # shellcheck disable=SC2206
        FILES+=($DIR "folder")
    done

    # Then add the files
    # shellcheck disable=SC2044
    # shellcheck disable=SC2044
    for FILE in $(find "$LOCAL_PATH" -maxdepth 1 -type f -name "$FILE_MASK" -printf "%f %s " 2> /dev/null)
    do
        # shellcheck disable=SC2206
        FILES+=($FILE)
    done

    while true
    do
        # shellcheck disable=SC2068
        # shellcheck disable=SC2068
        FILE_SELECTED=$(whiptail --clear --backtitle "$BACK_TITLE" --title "$TITLE" --menu "$LOCAL_PATH" 38 80 30 ${FILES[@]} 3>&1 1>&2 2>&3)

        if [ -z "$FILE_SELECTED" ]; then
            return 1
        else
            if [ "$FILE_SELECTED" = ".." ] && [ "$ALLOW_BACK" != "no" ]; then
                return 0

            elif [ -d "$LOCAL_PATH/$FILE_SELECTED" ] ; then
                if dr_file_select "$TITLE" "$LOCAL_PATH/$FILE_SELECTED" "$FILE_MASK" "yes" ; then
                    if [ "$FILE_SELECTED" != ".." ]; then
                        return 0
                    fi
                else
                    return 1
                fi

            elif [ -f "$LOCAL_PATH/$FILE_SELECTED" ] ; then
                FILE_SELECTED="$LOCAL_PATH/$FILE_SELECTED"
                return 0
            fi
        fi
    done
}

function dr_folder_select(){
    local TITLE=${1:-$MSG_INFO_TITLE}
    local LOCAL_PATH=${2:-$(pwd)}
    local FILE_MASK=${3:-"*"}
    local ALLOW_BACK=${4:-no}
    local FILES=()

    [ "$ALLOW_BACK" != "no" ] && FILES+=(".." "..")

    # First add folders
    # shellcheck disable=SC2044
    # shellcheck disable=SC2086
    FILES+=("../" "folder")
    # shellcheck disable=SC2044
    for DIR in $(find "$LOCAL_PATH" -maxdepth 1 -mindepth 1 -type d -printf "%f " 2> /dev/null)
    do
        # shellcheck disable=SC2206
        FILES+=($DIR "folder")
    done

    # Then add the files
    # shellcheck disable=SC2044
    # shellcheck disable=SC2044
    for FILE in $(find "$LOCAL_PATH" -maxdepth 1 -type f -name "$FILE_MASK" -printf "%f %s " 2> /dev/null)
    do
        # shellcheck disable=SC2206
        FILES+=($FILE)
    done

    while true
    do
        # shellcheck disable=SC2068
        # shellcheck disable=SC2068
        FILE_SELECTED=$(whiptail --clear --backtitle "$BACK_TITLE" --title "$TITLE" --menu "$LOCAL_PATH" 38 80 30 ${FILES[@]} 3>&1 1>&2 2>&3)

        if [ -z "$FILE_SELECTED" ]; then
            return 1
        else
            if [ "$FILE_SELECTED" = ".." ] && [ "$ALLOW_BACK" != "no" ]; then
                return 0

            elif [ -d "$LOCAL_PATH/$FILE_SELECTED" ] ; then
                if dr_file_select "$TITLE" "$LOCAL_PATH/$FILE_SELECTED" "$FILE_MASK" "yes" ; then
                    if [ "$FILE_SELECTED" != ".." ]; then
                        return 0
                    fi
                else
                    return 1
                fi

            elif [ -f "$LOCAL_PATH/$FILE_SELECTED" ] ; then
                FILE_SELECTED="$LOCAL_PATH/$FILE_SELECTED"
                return 0
            fi
        fi
    done
}

get_fileId(){
  regex='https\:\/\/drive\.google\.com/file/d/\(.*\)\/view'
  # shellcheck disable=SC2046
  # shellcheck disable=SC2046
  # shellcheck disable=SC2086
  # shellcheck disable=SC2027
  return $(echo "$1" | sed -n "s#"$regex"#\1#;p")
}

get_filename(){
  # shellcheck disable=SC2089
  regex="<title>\(.*\)\ \-\ Google\ Drive</title>"
  # shellcheck disable=SC2046
  # shellcheck disable=SC2086
  return $(wget -q --show-progress -O - "https://drive.google.com/file/d/$1/view" | sed -n -e 's!.*'"$regex"'.*!\1!p')
}

get_confirmCode(){
  url="https://docs.google.com/uc?export=download&id=$FILEID"
  regex="confirm=([0-9A-Za-z_]+)"
  # shellcheck disable=SC2046
  # shellcheck disable=SC2086
  return $(wget -q --show-progress --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "$url" -O- | sed -rn 's/.*'$regex'.*/\1\n/p')
}

checkurl() {
  FILEID=$(get_fileId "$1")
  if [ "$FILEID" != "$1" ]; then
    echo "url valida"
    return 1
  else
    echo "Please input 'https://drive.google.com/file/d/xxxxxxx/view'"
    return 0
  fi
}

check_quota(){
	FILENAME=$( get_filename "$1")
	if grep -q "Quota exceeded" "$FILENAME"; then
		# shellcheck disable=SC2086
		rm "$FILENAME" && \
		echo "Google Drive Limited (Quota Exceeded)" && \
		echo "file $FILENAME can NOT be downloaded"
		return 0
	else
		echo "file $FILENAME can be downloaded"
		return 1
	fi
}

check_downloaded(){
  FILENAME=$1
  if [ -f "$FILENAME" ]; then
        echo "file $FILENAME has been downloaded"
        return 1
      else
        echo "file $FILENAME cannot be downloaded,any error appear"
        return 0
      fi
}

download_file_drive(){
  # shellcheck disable=SC2046
  if [ $( checkurl "$1" ) = 1 ] ;then
    FILEID=$( get_fileId "$1" )
    if [ $( check_quota "$FILEID" ) = 1 ];then
      FILENAME=$( get_filename "$FILEID" )
      CONFIRM_CODE=$( get_confirmCode "$FILEID" )
      wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM_CODE&id=$FILEID" -c -O "$FILENAME" && rm -rf /tmp/cookies.txt;
      # shellcheck disable=SC2046
      return $( check_downloaded "$FILENAME" )
    else
      return 0
    fi
  else
    return 0
  fi
}

download_list_drive(){
  # shellcheck disable=SC2162
  while read p; do
    # shellcheck disable=SC2086
    download_file_drive "$p" #& # if uncomment the "&" it will download all the files at the same time,it can crash if had lots of files
    #if download an really big amount of downloads(more than 10 could do it) google drive will notice that it is an algorithim and will reduce the speed and maby block your ip to download(sometimes it gives exceded amount of downloads into the files)
    #	pidlist=("$pidlist[@]" $!)# $! = pid from process
  done < "$1"
}

advice() {
  whiptail --title "easy google drive downloader" --msgbox "programa sem fins lucrativos,qualquer uso feito do software é de responsabilidade do usuário. Escolha OK para continuar." --fb 15 60
}

download_option_menu() {
  item=$(whiptail --title "easy google drive downloader" --menu "escolha o tipo de download" --fb 15 60 4 \
    "1" "arquivo" \
    "2" "lista de arquivos" \
    "3" "pasta" \
    "4" "documento" 3>&1 1>&2 2>&3)
  status=$?
  if [ $status = 0 ]; then
    echo "Você escolheu a opção:" "$item"
    if [ "$item" = 1 ]; then
      echo "você escolheu arquivo"
    elif [ "$item" = 2 ]; then
      echo "você escolheu lista de arquivos"
    elif [ "$item" = 3 ]; then
      echo "você escolheu pasta"
    elif [ "$item" = 4 ]; then
      echo "você escoheu documento"
    fi
    return "$item"
  else
    echo "Opção cancelada."
  fi
}

insert_link() {
  nome=$(whiptail --title "easy google drive downloader" --inputbox "$1" --fb 10 60 3>&1 1>&2 2>&3)
  # shellcheck disable=SC2046
  # shellcheck disable=SC2046
  return $(checkurl "$nome")
}

main_menu(){
  opcao=download_option_menu

  # shellcheck disable=SC1035
  # shellcheck disable=SC2034
  if [ $opcao = 1 ];then
    #download directaly from drive
    link=$(insert_link "insira o link de download")
    retorno=$( download_file_drive "$link")
  elif [ $opcao = 2 ];then
    #download from list of links
    if dr_file_select "Please, select a file" ./ "*" "yes"; then
        $FILE_SELECTED
        retorno=$( download_file_drive "$link")
    else
        return 0
    fi

  elif [ $opcao = 3 ];then
    link=$(insert_link "insira o link de download")
    retorno=$( download_file_drive "$link")
  elif [ $opcao = 4 ];then
    link=$(insert_link "insira o link de download")

    retorno=$( download_file_drive "$link")
  fi
}

#if dr_file_select "Please, select a file" ./ "*" "yes"; then
#        echo "File Selected: \"$FILE_SELECTED\"."
#else
#        echo "Cancelled!"
#fi

# shellcheck disable=SC2044
for DIR in $(find "../" -maxdepth 1 -mindepth 1 -type d -printf "%f " )
    do
        # shellcheck disable=SC2206
        echo "$DIR"
    done

# shellcheck disable=SC2044
for FILE in $(find "../" -maxdepth 1 -type f -name "$FILE_MASK" -printf "%f %s " )
    do
        # shellcheck disable=SC2206
        echo "$FILE"
    done

echo "end"
