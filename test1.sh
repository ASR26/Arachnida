#!/bin/bash

# Get console options
SAVE_PATH="./data"
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

IMGFILE="img"
LINKFILE="href"
EXT_TXT="txt"
SRC_PATH=$(pwd)
DEEP=1

# Search and list href hyperlinks

curl -sSL  $URL | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | grep '/' | sort > $LINKFILE.$DEEP.$EXT_TXT;

N=2
while [[ $N -le $DEPTH ]]
	do
		for line in $(cat $LINKFILE.$DEEP.$EXT_TXT)
		do curl -sSL  $URL | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | grep '/' | sort > $LINKFILE.$N.$EXT_TXT;
		done
		DEEP="$N"
	(( N++ ))
done

# Create imagenes directory if it doesn't exist

cd "$SAVE_PATH"

# find img sources recursiverly and create a list in a file

curl -sSL  $URL | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 |cut -d "?" -f1 > $IMGFILE;

# copy img list file to parent dir

cp $IMGFILE $SRC_PATH

# Iterate each line in the file and download the file

for line in $(cat $IMGFILE)
	do 
	#	if [[ "$line" != "$URL*" ]];
	#	then
			curl -v -O $URL$line
	#	else
	#		curl -O $line
	#	fi
done

# removing img list file
rm $IMGFILE

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
