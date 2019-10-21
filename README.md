# Extracting-land-use-proportion-around-spatial-points-from-environmental-shapefiles
This script allows to extract land-use proportions around points in a given radius from land-use shapefiles, and then quickly
get theses proportions for any lower sizes of buffers. Outputs are in form of shapefiles and crossed tables to use information easily.
Mainly adapted for land-use shapefiles containing all types of land-use such as cesbio landcover shapefiles which can be downloaded here:
http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/vecteurs_2017/liste_vecteurs.html

# Extracting-land-use-proportion-around-spatial-points-from-one-environmental-raster
This script allows to extract land-use proportions around points in several radius sizes from a raster layer.
Land-use layer used available here: http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/OCS_2018_CESBIO.tif
Encapsulated in a function.

# Script used
- ExtractingLandUseBuffers.R # adapted for shapefile structure in the same form than cesbio shapefiles provided as example

# Data used
- departement_01.shp # first French department used as example which must be downloaded here: http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/vecteurs_2017/departement_01.zip
- departement_39.shp # second French department used as example which must be downloaded here: http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/vecteurs_2017/departement_39.zip
- points.shp # random points used as example
- DEPARTEMENT.shp # French departement layer allowing to only select in the script department layers (when a lot of layers are in the folder) containing points
