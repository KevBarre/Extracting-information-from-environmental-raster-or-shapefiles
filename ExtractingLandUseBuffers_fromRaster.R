##############################################################################################################
# This script allows to extract land-use proportions around points in several radius from a raster layer.
# Land-use layers used available here: http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/OCS_2018_CESBIO.tif
# With the help of Yves Bas
##############################################################################################################

# dir.posPoints = directory of point file location (ex: "C:/Users/barre/Desktop/")
# name.points = point file name, without extension (ex: "points")
# bw = one or several buffer size in meter (ex : 50 or c(50,100,200))
# id = column name to keep in the output (ex: "inc")
# dir.posEnvironmentalLayers = directory of raster location (only one) (ex: "C:/Users/barre/Desktop/raster.tiff")
# WorkingDirectory = directory at which to save the outpout (ex: "C:/Users/barre/Desktop/")

# Example :
# extractLandUseRaster=function(dir.posPoints = "C:/Users/barre/Desktop/", 
#                               name.points = "points", 
#                               bw = c(50,100,200), 
#                               id = "inc", 
#                               dir.posEnvironmentalLayers = "C:/Users/barre/Desktop/raster.tiff", 
#                               WorkingDirectory = "C:/Users/barre/Desktop/")
  
extractLandUseRaster=function(dir.posPoints, 
                              name.points, 
                              bw, 
                              id, 
                              dir.posEnvironmentalLayers, 
                              WorkingDirectory)
{
  # Required packages
  load <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg))
      install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)
  } 
  packages <- c("maptools","sp","raster","raster","lavaan")
  load(packages)
 
  setwd(WorkingDirectory)
  
  # Opening point shapefile
  Points<-readOGR(dsn = C:/Users/barre/documents/GitHub/Extracting-land-use-proportion-around-spatial-points-from-environmental-shapefiles, layer = name.points)
  
  # Converts coordinates into Lambert 93 (2154)
  Points <- spTransform (Points, CRS ("+init=epsg:2154"))
  
  bufwidth <- bw
  
  ID <- id
  
  Hab=raster(dir.posEnvironmentalLayers)
  
  #plot(Hab)
  
  HabufPropFinal = data.frame(Points[,ID])
  #HabufPropFinal = data.frame(Points[1:10,ID])
  
  for (j in bufwidth) {
    
    # Creating buffer around points
    
    Buffer = buffer(Points, width = j, dissolve = FALSE) 
    
    #plot(Points, add=T)
    
    HabufProp=list()
    
    for (i in 1:nrow(Buffer)) {
    #for (i in 1:10) {
      
      Habuf=extract(Hab,Buffer[i,])
      
      HabufProp[[i]]=as.data.table(t(as.matrix(table(Habuf))/sum(table(Habuf))))
      
      if(i%%100==1){print(paste("BufferSize",j,Sys.time()))}
      
    }
    
    HabufProp2=rbindlist(HabufProp,fill=T)
    
    HabufPropTemp = as.data.frame(HabufProp2)
    
    colnames(HabufPropTemp)=paste0(colnames(HabufPropTemp),"_", j)
    
    HabufPropFinal=cbind(HabufPropFinal, HabufPropTemp)
    
  }
  
  HabufPropFinal[is.na(HabufPropFinal)]=0
  
  fwrite(HabufPropFinal, "./crossedTableRaster.csv")
  
}
