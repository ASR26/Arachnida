#!/bin/bash

mkdir ./imagenes;
cd imagenes;
url=$1;
curl -sSL  $1 | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' |cut -d '"' -f2 |cut -d "?" -f1 > source.txt;

#curl -sSL  $1 | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | grep '/' > web.txt;

cp source.txt ../;
#cp web.txt ../;

for line in $(cat source.txt);
	do
		if [[ $line != $url* ]];
		then
			curl -O $url;	
			else
			curl -O $line; 
		fi
done

rm source.txt;
