

******************************************************************************
/*  Prepara mapa para calcular distancias. 
Descargado de: http://download.geofabrik.de/south-america/argentina.html */
******************************************************************************



*mapfile: ruta donde está el mapa que tiene que preparar
*osrmdir: ruta dnd guarda el resultado 
*profile: rutas que tiene que guardar (car, foot, bicycle)

*la ruta donde guardé el mapa que va a limpiar es esta: (el comando no lee espacios): 

osrmprepare, mapfile("C:\mymaps\argentina.osm.pbf")  profile(car) diskspace(6000)

