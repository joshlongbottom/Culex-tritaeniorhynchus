## script to generate multivariate environmental suitability surface
# clear workspace
rm(list = ls())

# load in packages 
source('code/packages.R')

# set the RNG seed
set.seed(1)

# load bespoke functions file
source('code/functions_culex.R')

# set output path
outpath <- 'output/vectors/'

## load the data
# raster covariates
covs_current <- brick('data/clean/raster/raster_current.grd')

# load in master mask for pseudo-absence generation
master_mask <- raster('data/clean/raster/master_mask.tif')

# rename the temporal layers (remove year)
names(covs_current)[names(covs_current)=='closed_shrublands_2012']<-'closed_shrublands'
names(covs_current)[names(covs_current)=='open_shrublands_2012']<-'open_shrublands'
names(covs_current)[names(covs_current)=='woody_savannas_2012']<-'woody_savannas'
names(covs_current)[names(covs_current)=='grasslands_2012']<-'grasslands'
names(covs_current)[names(covs_current)=='permanent_wetlands_2012']<-'permanent_wetlands'
names(covs_current)[names(covs_current)=='urban_and_built_up_2012']<-'urban_and_built_up'
names(covs_current)[names(covs_current)=='cropland_natural_vegetation_mosaic_2012']<-'cropland_natural_vegetation_mosaic'
names(covs_current)[names(covs_current)=='barren_or_sparsely_populated_2012']<-'barren_or_sparsely_populated'

# read in dat_covs model output
dat_covs <- read.csv('data/raw/dat_all/dat_all_18082016.csv',
                     stringsAsFactors = FALSE)

# just select covariate values (using col index)
dat_covs <- dat_covs[c(9:27)]

# create mess map (mess function)
mess_map <- mess(covs_current, dat_covs, full = TRUE)

# save rmess layer and the raster stack
writeRaster(mess_map[['rmess']], 
            file='output/mess_raw', 
            format='GTiff', 
            overwrite=TRUE)

writeRaster(mess_map, 
            file='output/mess_maps',
            overwrite=TRUE)

# make binary, interpolation/extrapolation surface and save
tmp <- mess_map[['rmess']] >= 0

# crop to extent
tmp_masked <- mask(tmp, master_mask)

# write to disk
writeRaster(tmp_masked, 
            file='output/mess_binary_non-leverage', 
            format='GTiff', 
            overwrite=TRUE)

