# importamos las librerías necesarias
from PIL import Image
from PIL.ExifTags import TAGS
import sys

# importamos el sistema para ver los argumentos

import sys

imagename = sys.argv[1]
# leemos los datos de la imagen con PIL
image = Image.open(imagename)

# extraemos metadatos básicos y los asignamos a un objeto JSON
info_dict = {
    "Filename": image.filename,
    "Image Size": image.size,
    "Image Height": image.height,
    "Image Width": image.width,
    "Image Format": image.format,
    "Image Mode": image.mode,
    "Image is Animated": getattr(image, "is_animated", False),
    "Frames in Image": getattr(image, "n_frames", 1)
}

#imprimimos la información que hemos sacado antes

for label,value in info_dict.items():
    print(f"{label:25}: {value}")
    
# extraemos los datos EXIF
exifdata = image._getexif()

# recorremos los datos que acabamos de extraer, en caso de que no haya imprimiremos el mensaje "No EXIF data"
if (exifdata is not None):
    for tag_id in exifdata:
     # get the tag name, instead of human unreadable tag id
     if (tag_id != null):
         tag = TAGS.get(tag_id, tag_id)
         data = exifdata.get(tag_id)
         # decode bytes 
         if isinstance(data, bytes):
             data = data.decode()
         print(f"{tag:25}: {data}")
else:
    print("No EXIF data")
