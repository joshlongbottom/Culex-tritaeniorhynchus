#clear workspace
rm(list = ls ())

# load packages
library(seegSDM)
library(raster)
library(snowfall)
library(GRaF)

# organise covariates for analysis
# read in a list of the covariates to be used in the model
cov_list <- read.csv('data/raw/raster/covariates_for_model.csv',
                     stringsAsFactors = FALSE)

# create a list to loop through and open
covars <- as.list(cov_list$cov_path)
            
# create list of names to rename covs by
names <- as.list(cov_list$cov_name)

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