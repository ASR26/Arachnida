#!/bin/bash

# Get console options
SAVE_PATH="./data"
LINKS_PATH="./links"
while getopts "r:l:p:" FLAG
do
	case "${FLAG}" in
	r)
		URL="${OPTARG}"
		echo "la url es: $URL"
		;;
	l)
		DEPTH="${OPTARG}"
		if [ -z "${OPTARG}" ] ; then
			DEPTH=5

		else
			DEPTH="${OPTARG}"
			echo "El nivel de recursividad es: $DEPTH"
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
[ ! -d "$LINKS_PATH" ] && mkdir -p ""$LINKS_PATH

IMGFILE="img"
LINKFILE="href"
EXT_TXT="txt"
SRC_PATH=$(pwd)
DEEP=1

# Search and list href hyperlinks

curl -sSL  $URL | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | grep '/' | sort |uniq >> "links/$LINKFILE.$DEEP.$EXT_TXT";

N=2
while [[ $N -le $DEPTH ]]
	do
		for line in $(cat "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT")
		do
			if [[ "$line" =~ ^"/.*"  ]]
			then
			curl -sSL  $URL$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' |  cut -d '"' -f2 | grep '/' | sort |uniq >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			elif [[ "$line" == "$URL*" ]]
				then
			 	curl -sSL  $line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | sort |uniq >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			elif [[ "$line" == ^"[a-zA-Z0-9]" ]]
			then
			curl -sSL  $URL/$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' |  cut -d '"' -f2 | grep '/' | sort |uniq >> "$LINKS_PATH/$LINKFILE.$N.$EXT_TXT";
			fi
			cat "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT" |uniq >> "$LINKS_PATH/$LINKFILE.$EXT_TXT"
		done
		DEEP="$N"
	(( N++ ))
done
#cat $LINKFILE.$EXT_TXT |uniq > $LINKFILE.$EXT_TXT

# Create imagenes directory if it doesn't exist
cp "$LINKS_PATH/$LINKFILE.$EXT_TXT" $SAVE_PATH
cd "$SAVE_PATH"

# find img sources recursiverly and create a list in a file
		for line in $(cat "../$LINKS_PATH/$LINKFILE.$EXT_TXT")
		do
			curl -sSL  $line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 | cut -d "'" -f2 |cut -d "?" -f1 | sort |uniq >> $IMGFILE.$EXT_TXT;
	done
# copy img list file to parent dir

#cp $IMGFILE.$EXT_TXT $SRC_PATH
#cd $SRC_PATH

# Iterate each line in the file and download the file
cat "$IMGFILE.$EXT_TXT" |uniq > temp.txt
mv temp.txt "$IMGFILE.$EXT_TXT"

for line in $(cat "$IMGFILE.$EXT_TXT")
	do 
		if [[ "$line" =~ ^"/" ]];
		then
			curl -O "$URL$line"
		else
			curl -O $line
		fi

	done

# removing img list file
rm $IMGFILE.$EXT_TXT

cd $SRC_PATH

#mkdir ./imagenes;
#cd imagenes;
#URL=$1;
#echo "$URL"
#
#cp source.txt ../;
#cp web.txt ../;
#
#for line in $(cat source.txt);
#	done
#
#rm source.txt;
