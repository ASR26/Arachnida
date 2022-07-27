#!/bin/bash

# Get console options
SAVE_PATH="data"
LINKS_PATH="links"
DEPTH=5
while getopts "r:l:p:" FLAG
do
	case "${FLAG}" in
	r)
		URL="${OPTARG}"
#		if [[ $URL != https* ]]
#		then
#			echo "Escribe la URL con el formato: https://dominio.com"
#			exit 1
#		fi
		echo "la url es: $URL"
		;;
	l)
		DEPTH="${OPTARG}"
		if [ -z "${OPTARG}" ] ; then
			DEPTH=5
		else
			DEPTH="${OPTARG}"
		fi
		;;
	p)
		if [ -z "${OPTARG}" ]; then
				SAVE_PATH="./data"
				echo "El path es: ./data"
		else
				SAVE_PATH="${OPTARG}"
				echo "El path es: ./$SAVE_PATH"
		fi
		;;
	*)
		echo "Opción inválida"
		;;
	esac
done
	# Controla modificadores inexistentes
	shift $(($OPTIND - 1))
	set +x

[ ! -d "$SAVE_PATH" ] && mkdir -p "$SAVE_PATH"
[ ! -d "$LINKS_PATH" ] && mkdir -p "$LINKS_PATH"

echo "El nivel de recursividad es: $DEPTH"
IMGFILE="img"
LINKFILE="href"
EXT_TXT="txt"
SRC_PATH=$(pwd)
DEEP=1

# Search and list href hyperlinks

#curl -sSL  $URL | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 |cut -d "&" -f1 | grep '/' |sort -u >> "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT";

echo $URL > "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT";
echo "Searching links"
cat "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT" > "$LINKS_PATH/$LINKFILE.$EXT_TXT"
N=2
while [[ $N -le $DEPTH ]]
	do
		for line in $(cat "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT")
		do
			if [[ "$line" == ^/$ ]]
			then
				continue
			elif [[ "$line" == http*  ]]
			then
				curl -sSL  $line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' |awk -F '"' '{print $2}' |cut -d "?" -f1 |cut -d "&" -f1 |grep "/" |sort -u >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL != https://* ]]
			then
			 	curl -sSL  "https://"$URL//$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' |cut -d '"' -f2 |cut -d "?" -f1 |cut -d "&" -f1 |grep "/" |sort -u >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL == https://* ]]
			then
curl -sL  $URL//$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' |cut -d '"' -f2 |cut -d "?" -f1 |cut -d "&" -f1 |grep "/" |sort -u >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			elif [[ $line == ^/* ]]
			then
				curl -sSL  "https://"$URL$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' |cut -d '"' -f2 |cut -d "?" -f1 |cut -d "&" -f1 |grep "/" |sort -u >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			fi
				cat "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT" |grep "/" |sort -u >> "$LINKS_PATH/$LINKFILE.$EXT_TXT"
		done
		DEEP="$N"
	(( N++ ))
done
cat "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT" |grep "/" |sort -u >> "$LINKS_PATH/$LINKFILE.$EXT_TXT"

cat "$LINKS_PATH/$LINKFILE.$EXT_TXT" |sort -u  > "$LINKS_PATH/tmp.txt"
mv "$LINKS_PATH/tmp.txt" "$LINKS_PATH/$LINKFILE.$EXT_TXT"
echo "Links found"
echo "Searching images"
# Create imagenes directory if it doesn't exist
cp "$LINKS_PATH/$LINKFILE.$EXT_TXT" $SAVE_PATH
cd "$SAVE_PATH"
cat "$LINKFILE.$EXT_TXT" |sort -u > temp.txt
mv temp.txt "$LINKFILE.$EXT_TXT"


# find img sources recursiverly and create a list in a file
		for line in $(cat "$LINKFILE.$EXT_TXT")
		do
			if [[ $line == http* || $line == $URL ]]
			then
				curl -sSL  $line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 | cut -d "'" -f2 |cut -d "?" -f1 |cut -d "&" -f1 |sort -u >> $IMGFILE.$EXT_TXT;
			elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL != https://* ]]
			then
				curl -sSL "https://"$URL$line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 | cut -d "'" -f2 |cut -d "?" -f1 |cut -d "&" -f1 |sort -u >> $IMGFILE.$EXT_TXT;
			elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL == https://* ]]
			then
				curl -sSL $URL//$line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 | cut -d "'" -f2 |cut -d "?" -f1 |cut -d "&" -f1 |sort -u >> $IMGFILE.$EXT_TXT;
			elif [[ $line == ^/* ]]
			then
				curl -sSL "https://"$URL$line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 | cut -d "'" -f2 |cut -d "?" -f1 |cut -d "&" -f1 |sort -u >> $IMGFILE.$EXT_TXT;
			fi
	done

echo "Images found"
echo "Downloading images"
# copy img list file to parent dir

#cp $IMGFILE.$EXT_TXT $SRC_PATH
#cd $SRC_PATH

# Iterate each line in the file and download the file

cat "$IMGFILE.$EXT_TXT" |sort -u > temp.txt
mv temp.txt "$IMGFILE.$EXT_TXT"

for line in $(cat $IMGFILE.$EXT_TXT)
do
    if [[ "$line" == http* ]]
        then
        curl -OsL $line;
	elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL != https://* && $line != $URL ]]
       then
		  curl -OL "https://"$URL//$line
	  elif 	[[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL == https://* ]]
  then
		  curl -OsL $URL//$line
    elif [[ $line ==  /* ]]
        then
        curl -OsL $URL$line;
    fi
done
echo "Download finished"
# removing img list file
#rm $IMGFILE.$EXT_TXT
#rm $LINKFILE.$EXT_TXT
#cd ..
#rm -rf $LINKS_PATH
