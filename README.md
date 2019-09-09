# Extracting-land-use-proportion-around-spatial-points-from-environmental-shapefiles
This script allows to extract land-use proportions around points in a given radius from land-use shapefiles, and then quickly
get theses proportions for any lower sizes of buffers. Outputs are in form of shapefiles and crossed tables to use information easily.
Mainly adapted for land-use shapefiles containing all types of land-use such as cesbio landcover shapefiles which can be downloaded here:
http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/vecteurs_2017/liste_vecteurs.html

# Script used
- ExtractingLandUseBuffers.R # adapted for shapefile structure in the same form than cesbio shapefiles provided as example

# Data used
- departement_01.shp # first French department used as example
- departement_39.shp # second French department used as example
- points.shp # random points used as example
- DEPARTEMENT.shp # French departement layer allowing to only select in the script department layers (when a lot of layers are in the folder) containing points
