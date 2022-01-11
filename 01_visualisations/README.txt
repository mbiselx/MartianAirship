To make the images you will need to install the Matlab Image Processing toolbox, and retrieve the two datasets from the links provided below. The datasets need to be placed in the folder named 'data' before the script can be run.  
The first time the script is run after startup, it needs to read the datasets - this can take a little while. After that, it should be faster. 
The elevation model and texture model only agree to within a few kilometers - some tuning of the correction parameters may be required, if you want to render the landscape "up close"

Mars Digital Elevation Model : MOLA Team, Mars MGS MOLA DEM 463m v2, GeoScience PDS Node, January 2014
https://planetarymaps.usgs.gov/mosaic/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif 

Mars Color & Texture Model 1: Mars Global Data Sets, Viking Merged Color Mosaic, retrieved 03.01.2022 
http://www.mars.asu.edu/data/mdim_color/large/mars45s315.png 

Mars Color & Texture Model 2: Mars Odyssey THEMIS, Valles Marineris, a Martian Rift Zone, retrieved 07.01.2022 
http://themis.asu.edu/files/features/016_valles_rift/016vallesmarineris.jpg 




The Mars Climate Database and data derived from it is NOT included in this git repo - I have only included my own work. 

A web interface to the MCD can be found at : 
http://www-mars.lmd.jussieu.fr/mcd_python/ 

Many thanks to them for letting us use their database for this project. 