# clear workspace
rm(list = ls ())

# load packages
source('code/packages.R')

covs_current <- brick('data/clean/raster/raster_current.gri')

TCB_SD <- covs_current[[1]]
LSTday_mean <- covs_current[[2]]
LSTday_SD <- covs_current[[3]]                               
LSTnight_mean <- covs_current[[4]]
LSTnight_SD <- covs_current[[5]]
TCW_mean <- covs_current[[6]]                               
TCW_SD <- covs_current[[7]]
SRTM_elevation <- covs_current[[8]]
closed_shrublands_2012 <- covs_current[[9]]                 
open_shrublands_2012 <- covs_current[[10]]
woody_savannas_2012 <- covs_current[[11]]
grasslands_2012 <- covs_current[[12]]                        
permanent_wetlands_2012 <- covs_current[[13]]
croplands_2012 <- covs_current[[14]]
urban_and_built_up_2012 <- covs_current[[15]]                
cropland_natural_vegetation_mosaic_2012 <- covs_current[[16]]
barren_or_sparsely_populated_2012 <- covs_current[[17]] 

writeRaster(TCB_SD,
            file = 'data/raw/raster/current/TCB_SD',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(LSTday_mean,
            file = 'data/raw/raster/current/LSTday_mean',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(LSTday_SD,
            file = 'data/raw/raster/current/LSTday_SD',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(LSTnight_mean,
            file = 'data/raw/raster/current/LSTnight_mean',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(LSTnight_SD,
            file = 'data/raw/raster/current/LSTnight_SD',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(TCW_mean,
            file = 'data/raw/raster/current/TCW_mean',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(TCW_SD,
            file = 'data/raw/raster/current/TCW_SD',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(SRTM_elevation,
            file = 'data/raw/raster/current/SRTM_elevation',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(closed_shrublands_2012,
            file = 'data/raw/raster/current/closed_shrublands_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(open_shrublands_2012,
            file = 'data/raw/raster/current/open_shrublands_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(woody_savannas_2012,
            file = 'data/raw/raster/current/woody_savannas_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(grasslands_2012,
            file = 'data/raw/raster/current/grasslands_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(permanent_wetlands_2012,
            file = 'data/raw/raster/current/permanent_wetlands_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(croplands_2012,
            file = 'data/raw/raster/current/croplands_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(urban_and_built_up_2012,
            file = 'data/raw/raster/current/urban_and_built_up_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(cropland_natural_vegetation_mosaic_2012,
            file = 'data/raw/raster/current/cropland_natural_vegetation_mosaic_2012',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(barren_or_sparsely_populated_2012,
            file = 'data/raw/raster/current/barren_or_sparsely_populated_2012',
            format = "GTiff",
            overwrite = TRUE)
