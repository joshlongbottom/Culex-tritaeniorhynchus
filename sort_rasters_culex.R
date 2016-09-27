#clear workspace
rm(list = ls ())

# load packages
library(seegSDM)
library(raster)
library(snowfall)
library(GRaF)

# organise covariates for analysis
# list the covariates of interest
covars <- c('data/raw/raster/covariates -29012016/tasselled cap brightness/TCB_Mean_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/tasselled cap brightness/TCB_SD_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/enhanced vegetation index/EVI_Fixed_Mean_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/enhanced vegetation index/EVI_Fixed_SD_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/land surface temp/LST_Day_Mean_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/land surface temp/LST_Day_SD_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/land surface temp/LST_Night_Mean_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/land surface temp/LST_Night_SD_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/tasselled cap wetness/TCW_Mean_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/tasselled cap wetness/TCW_SD_5km_Mean_DEFLATE.ABRAID_Extent.Gapfilled.tif',
            'data/raw/raster/covariates -29012016/elevation/mod_dem_5k_CLEAN.flt',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2001.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2002.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2003.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2004.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2005.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2006.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2007.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2008.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2009.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2010.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2011.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class06_Closed_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class07_Open_Shrublands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class08_Woody_Savannas.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class10_Grasslands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class11_Permanent_Wetlands.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class13_Urban_And_Built_Up.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class14_Cropland_Natural_Vegetation_Mosaic.5km.Percentage.tif',
            'data/raw/raster/covariates -29012016/landcover 2001-12/2012.Class16_Barren_Or_Sparsely_Populated.5km.Percentage.tif')
            
# give them readable names
names <- c('TCB_mean', 
           'TCB_SD',
           'EVI_mean',
           'EVI_SD',
           'LSTday_mean',
           'LSTday_SD',
           'LSTnight_mean',
           'LSTnight_SD',
           'TCW_mean',
           'TCW_SD',
           'SRTM_elevation',
           'closed_shrublands_2001',
           'open_shrublands_2001',
           'woody_savannas_2001',
           'grasslands_2001',
           'permanent_wetlands_2001',
           'urban_and_built_up_2001',
           'cropland_natural_vegetation_mosaic_2001',
           'barren_or_sparsely_populated_2001',
           'closed_shrublands_2002',
           'open_shrublands_2002',
           'woody_savannas_2002',
           'grasslands_2002',
           'permanent_wetlands_2002',
           'urban_and_built_up_2002',
           'cropland_natural_vegetation_mosaic_2002',
           'barren_or_sparsely_populated_2002',
           'closed_shrublands_2003',
           'open_shrublands_2003',
           'woody_savannas_2003',
           'grasslands_2003',
           'permanent_wetlands_2003',
           'urban_and_built_up_2003',
           'cropland_natural_vegetation_mosaic_2003',
           'barren_or_sparsely_populated_2003',
           'closed_shrublands_2004',
           'open_shrublands_2004',
           'woody_savannas_2004',
           'grasslands_2004',
           'permanent_wetlands_2004',
           'urban_and_built_up_2004',
           'cropland_natural_vegetation_mosaic_2004',
           'barren_or_sparsely_populated_2004',
           'closed_shrublands_2005',
           'open_shrublands_2005',
           'woody_savannas_2005',
           'grasslands_2005',
           'permanent_wetlands_2005',
           'urban_and_built_up_2005',
           'cropland_natural_vegetation_mosaic_2005',
           'barren_or_sparsely_populated_2005',
           'closed_shrublands_2006',
           'open_shrublands_2006',
           'woody_savannas_2006',
           'grasslands_2006',
           'permanent_wetlands_2006',
           'urban_and_built_up_2006',
           'cropland_natural_vegetation_mosaic_2006',
           'barren_or_sparsely_populated_2006',
           'closed_shrublands_2007',
           'open_shrublands_2007',
           'woody_savannas_2007',
           'grasslands_2007',
           'permanent_wetlands_2007',
           'urban_and_built_up_2007',
           'cropland_natural_vegetation_mosaic_2007',
           'barren_or_sparsely_populated_2007',
           'closed_shrublands_2008',
           'open_shrublands_2008',
           'woody_savannas_2008',
           'grasslands_2008',
           'permanent_wetlands_2008',
           'urban_and_built_up_2008',
           'cropland_natural_vegetation_mosaic_2008',
           'barren_or_sparsely_populated_2008',
           'closed_shrublands_2009',
           'open_shrublands_2009',
           'woody_savannas_2009',
           'grasslands_2009',
           'permanent_wetlands_2009',
           'urban_and_built_up_2009',
           'cropland_natural_vegetation_mosaic_2009',
           'barren_or_sparsely_populated_2009',
           'closed_shrublands_2010',
           'open_shrublands_2010',
           'woody_savannas_2010',
           'grasslands_2010',
           'permanent_wetlands_2010',
           'urban_and_built_up_2010',
           'cropland_natural_vegetation_mosaic_2010',
           'barren_or_sparsely_populated_2010',
           'closed_shrublands_2011',
           'open_shrublands_2011',
           'woody_savannas_2011',
           'grasslands_2011',
           'permanent_wetlands_2011',
           'urban_and_built_up_2011',
           'cropland_natural_vegetation_mosaic_2011',
           'barren_or_sparsely_populated_2011',
           'closed_shrublands_2012',
           'open_shrublands_2012',
           'woody_savannas_2012',
           'grasslands_2012',
           'permanent_wetlands_2012',
           'urban_and_built_up_2012',
           'cropland_natural_vegetation_mosaic_2012',
           'barren_or_sparsely_populated_2012')

# loop through opening links to the rasters
covs <- lapply(covars, raster)

# read in study extent shapefile
study_extent <-shapefile('data/raw/extent/culex_extent_rawv2.shp')

# get the extents of all of the covariates
extents <- t(sapply(covs, function (x) as.vector(extent(x))))

# get the extent of the study extent shapefile
culex_extent <- extent(study_extent)

# crop raster layers by the extent of study extent
covs <- lapply(covs, crop, culex_extent)

# stack the rasters
covs <- stack(covs) 

# plot covariates to check crop process
plot(covs)

# loop through covariate layers, find any NAs,
# find the cov with most NAs, and mask the whole stack by this layer
master_mask <- masterMask(covs)

# mask all covariates by master mask
covs <- mask(covs, master_mask)

# change the names of the covariates
# first paste their current names, and the new names to the console
cbind(names(covs), names)
warning('check the names match up!')

# if they match, rename
names(covs) <- names

# subset covariates to create stacks of temporal, 
# non-temporal and the most contemporary covariates
covs_current <- subset(covs, c(1:11, 100:107))
covs_temporal <- subset(covs, 12:107)
covs_nontemporal <- subset(covs, 1:11)

# output them as multiband .grd files
writeRaster(covs_current,
            file = 'data/clean/raster/raster_current',
            overwrite = TRUE)

writeRaster(covs_temporal,
            file = 'data/clean/raster/raster_temporal',
            overwrite = TRUE)

writeRaster(covs_nontemporal,
            file = 'data/clean/raster/raster_nontemporal',
            overwrite = TRUE)

# write out the master mask for reference
writeRaster(master_mask,
            file = 'data/clean/raster/master_mask',
            format = "GTiff",
            overwrite = TRUE)