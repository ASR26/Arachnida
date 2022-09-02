# Descripción
Este proyecto consta de dos programas. El primero `spider.sh` es un [web scraper](https://es.wikipedia.org/wiki/Web_scraping) que descargará todas las imágenes de una web, y el otro `scorpion.sh` es un "analizador" de imágenes, que nos permitirá leer los [metadatos](https://www.adslzone.net/reportajes/tecnologia/metadatos-que-son/) de cualquier imagen.

## Funcionamiento Spider
Para ejecutar el spider.sh se hará de la siguiente forma:
```
./spider.sh -r <url>
```
### Flags
Este programa cuenta con 3 opciones diferentes:
- -r: Será la opción con la que le diremos que web tiene que explorar (es necesaria para que el programa funcione).
- -l: Servirá para definir la profundidad de la recursividad que queremos (por defecto está en 5), es decir, a cuantos niveles de profundidad queremos que llegue siguiendo enlaces de la página.
- -p: Con esta opción podremos cambiar el nombre de la carpeta donde se guardarán las imágenes descargadas (por defecto será `data`).

## Funcionamiento Scorpion
Para ejecutar el scorpion.sh se hará de la siguiente forma:
```
./scorpion.sh <imagen>
```
Se le pueden dar como parámetros tantas imágenes como se quiera y mostrará tanto sus metadatos como sus datos Exif
