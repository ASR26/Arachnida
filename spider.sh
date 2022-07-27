#!/bin/bash

# Cogemos las opciones de consola con getopts
SAVE_PATH="data"
LINKS_PATH="links"
DEPTH=5
while getopts "r:l:p:" FLAG
do
	case "${FLAG}" in
	r)
		URL="${OPTARG}"
		echo "la url es: $URL"
		;;
	l)
		DEPTH="${OPTARG}"
		;;
	p)
		SAVE_PATH="${OPTARG}"
		;;
	*)
		echo "Opción inválida"
		;;
	esac
done
	# Controla modificadores inexistentes
	shift $(($OPTIND - 1))
	set +x

# Si no existen las carpetas de descarga y de linjs las creamos
[ ! -d "$SAVE_PATH" ] && mkdir -p "$SAVE_PATH"
[ ! -d "$LINKS_PATH" ] && mkdir -p "$LINKS_PATH"

echo "La ruta de descarga es: $SAVE_PATH"
echo "El nivel de recursividad es: $DEPTH"
IMGFILE="img"
LINKFILE="href"
EXT_TXT="txt"
SRC_PATH=$(pwd)
DEEP=1

echo $URL > "$LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT";
echo "Buscando los enlaces"

# Creamos un archivo href.1.txt donde metemos el enlace que se ha dado y lo escribimos en href.txt, y en caso de que haya recursividad mayor de 1 buscaremos los enlaces que haya en esta página,
# los meteremos en href.2.txt y cuando los tengamos todos lo meteremos en el href.txt, así sucesivamente, siempre leyendo el último archivo con número

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

# Eliminamos los posibles duplicados que haya en el archivo final

cat "$LINKS_PATH/$LINKFILE.$EXT_TXT" |sort -u  > "$LINKS_PATH/tmp.txt"
mv "$LINKS_PATH/tmp.txt" "$LINKS_PATH/$LINKFILE.$EXT_TXT"
echo "Enlaces encontrados"
cp "$LINKS_PATH/$LINKFILE.$EXT_TXT" $SAVE_PATH
cd "$SAVE_PATH"
cat "$LINKFILE.$EXT_TXT" |sort -u > temp.txt
mv temp.txt "$LINKFILE.$EXT_TXT"


# Buscamos las imágenes y guardamos los enlaces en un archivo, que usaremos para descargarlas

echo "Buscando imágenes"
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

echo "Imagenes encontradas"

# Eliminamos los posibles duplicados del archivo

cat "$IMGFILE.$EXT_TXT" |sort -u > temp.txt
mv temp.txt "$IMGFILE.$EXT_TXT"

echo "Descargando imágenes"

# Recorremos las líneas descargando cada una de las imágenes

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
echo "Descarga completada"
# Borramos los archivos de enlace junto con la carpeta y el archivo de texto con las imágenes 
rm $IMGFILE.$EXT_TXT
rm $LINKFILE.$EXT_TXT
cd ..
rm -rf $LINKS_PATH
