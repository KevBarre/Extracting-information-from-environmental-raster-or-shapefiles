#######################################################################################################################################
# This script allows to extract land-use proportions around points in a given radius from land-use shapefiles, and then quickly
# get theses proportions for any lower sizes of buffers. Outputs are in form of shapefiles and crossed tables to use information easily.
# Mainly adapted for land-use shapefiles containing all types of land-use.
# Land-use layers used available here: http://osr-cesbio.ups-tlse.fr/echangeswww/TheiaOSO/vecteurs_2017/liste_vecteurs.html
#######################################################################################################################################

rm(list=ls())

# Required packages
require(rgdal)
require(maptools)
library(maps)
require(gridExtra)
require(rgeos)
require(dplyr)
library(sp)
library(raster)
library(GISTools)
library(sf)

setwd("./") # working directory for saving crossed tables
dir.posPoints = "./" # point files location
dir.posEnvironmentalLayers = "./" # shapefiles location, here one per French departement, all including all land-use types
dir.posFrenchDepartment = "./" # French department shapefile location
points = "points" # point file name, without extension

# Opening point shapefile

Points<-readOGR(dsn = dir.posPoints, layer = points)

# Converts coordinates into Lambert 93 (2154)

Points <- spTransform (Points, CRS ("+init=epsg:2154"))

# Creating buffer around points

Buffer = buffer(Points, width = 4000, dissolve = FALSE) 

# Keeping spatial identifiers of points

Buffer = cbind(Buffer, ID = c(1:length(Buffer)))

names(Buffer)[[6]] <- "ID" # ensure that your identifier column is well named ID

# To know which layers include to avoid further empty intersections

FrenchDepartements<-readOGR(dsn = dir.posFrenchDepartment, layer = "DEPARTEMENT")

FrenchDepartements <- spTransform (FrenchDepartements, CRS ("+init=epsg:2154"))

Buffer_FrenchDepartements = raster::intersect(Buffer, FrenchDepartements) # cutting

CodeDepartement = unique(Buffer_FrenchDepartements$CODE_DEPT)

CodeDepartement2 = paste0("departement_", CodeDepartement, sep = "") # to make same names than shapefiles ones

# List of desired environmental shapefiles

list1 <- list.files(dir.posEnvironmentalLayers, pattern = ".shp",recursive=TRUE,include.dirs = TRUE)

list2 = sub(".shp", "", list1) # keeping only names without .shp extensions

list2=list2[which(list2 %in% CodeDepartement2)] # keeping only layers which contain buffers

# Extracting environmental shapefiles included inside buffers, here one layer per French department

for (k in 1:length(unique(list2))){ 
  
  print(unique(list2)[k])
  
  # Load the environmental layer
  
  Vegetation_temp<-readOGR(dsn = dir.posEnvironmentalLayers, layer = unique(list2)[k])
  
  # Converts coordinates into Lambert 93 (2154)
  
  Vegetation_temp <- spTransform (Vegetation_temp, CRS ("+init=epsg:2154"))
  
  if(k-1 == 0){ # for the first one only intersect
  
  Buffer_vegetation_temp = raster::intersect(Buffer, Vegetation_temp) # cutting
  
  } else{ # for the following layer aggregating results with previous ones
    
    try = tryCatch({ # to not stop the process if an error occurs due to buffers which do not intersect the layer
    
    Buffer_vegetation_temp_new = raster::intersect(Buffer, Vegetation_temp) # cutting
    
    Buffer_vegetation_temp = rbind(Buffer_vegetation_temp, Buffer_vegetation_temp_new, makeUniqueIDs = TRUE) # aggregating
    
    }, error = function(e) {
      
      print(paste0("Error in layer", unique(list2)[k]))
      
    })
    
  }
  
  rm(Vegetation_temp) # removing the layer from the memory
  
}

writeOGR(obj=Buffer_vegetation_temp, dsn=dir.posPoints, layer="Intersection", driver="ESRI Shapefile") # saving

# pre-visualization of the result

head(Buffer_vegetation_temp@data) 

# Crossed table to get surfaces and proportion of each land-use type inside each buffer identifier

ID = c()
buffer = 4000
surface = (buffer/2)^2 * 3.14
tableFinal = c()

for(i in unique(Buffer_vegetation_temp$ID)){
  
  print(i)
  
  table = cbind(ID, ID = i)
  
  sub = subset(Buffer_vegetation_temp, Buffer_vegetation_temp$ID == i)
  
  for(j in 11:27){
    
    print(names(sub[j]))
    
    tableNew = c()
    
    sum = c()
    
    proportion = c()
    
    sum = c(sum,sum(sub[[j]]))
    
    proportion = c(proportion,(sum * 100)/surface)
    
    tableNew = cbind(sum, proportion)
    
    colnames(tableNew) <- c(paste("sum","_",names(sub[j]), sep = ""), paste("proportion","_",names(sub[j]), sep = ""))
    
    table = cbind(table, tableNew)
    
  }
  
  tableFinal = rbind(tableFinal, table)
  
}

write.csv(tableFinal, "./crossedTable.csv") # saving

# Get results for several smaller buffers without remake previous steps

# Opening point shapefile

Points<-readOGR(dsn = dir.posPoints, layer = points)

# Converts coordinates into Lambert 93 (2154)

Points <- spTransform (Points, CRS ("+init=epsg:2154"))

# Load the environmental layer

WideBuffer<-readOGR(dsn = dir.posPoints, layer = "Intersection")

# Converts coordinates into Lambert 93 (2154)

WideBuffer <- spTransform (WideBuffer, CRS ("+init=epsg:2154"))

# creating desired buffer sizes 

bufferSizes = c(3000, 2000, 1000, 500) # example using 3000, 2000, 1000 and 500 m buffers

for (k in bufferSizes) {
  
  print(k)
  
  # Creating buffer around points
  
  SmallBuffer = buffer(Points, width = k, dissolve = FALSE) 
  
  # Cutting initial wide buffer layer into desired new buffer size
  
  WideSmallBuffer=raster::intersect(SmallBuffer, WideBuffer) 
  
  WideSmallBuffer=WideSmallBuffer[,-c(1:5)]
  
  writeOGR(obj=WideSmallBuffer, dsn=dir.posPoints, layer=paste("Intersection", k, sep = ""), driver="ESRI Shapefile") # saving
  
  # Crossed table to get surfaces and proportion of each land-use type inside each buffer
  
  ID = c()
  buffer = k
  surface = (buffer/2)^2 * 3.14
  tableFinal = c()
  
  for(i in unique(WideSmallBuffer$ID)){
    
    print(i)
    
    table = cbind(ID, ID = i)
    
    sub = subset(WideSmallBuffer, WideSmallBuffer$ID == i)
    
    for(j in 13:27){
      
      #print(names(sub[j]))
      
      tableNew = c()
      
      sum = c()
      
      proportion = c()
      
      sum = c(sum,sum(sub[[j]]))
      
      proportion = c(proportion,(sum * 100)/surface)
      
      tableNew = cbind(sum, proportion)
      
      colnames(tableNew) <- c(paste("sum","_",names(sub[j]), sep = ""), paste("proportion","_",names(sub[j]), sep = ""))
      
      table = cbind(table, tableNew)
      
    }
    
    tableFinal = rbind(tableFinal, table)
    
  }
  
  write.csv(tableFinal, paste("./crossedTable", k, ".csv", sep = "")) # saving
  
}
