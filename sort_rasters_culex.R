#clear workspace
rm(list = ls ())

# load packages
source('code/packages.R')

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
study_extent <-shapefile('data/raw/extent/je_cdc_extent_buffered.shp')

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
covs_current <- subset(covs, c(1:8, 108:116))
covs_temporal <- subset(covs, 9:116)
covs_nontemporal <- subset(covs, 1:8)

## check correlation between covariates
# create a random sample of locations
pts <- bgSample(covs_current[[1]], n = 1000, spatial = FALSE)

# get the values of all covariates at these points
vals <- extract(covs_current, pts)

# check for NAs at each of the locations, across all covariates
any(is.na(vals))

# build correlation matrix removing NAs
cor <- cor(na.omit(vals), method='spearman')

# plot correlation matrix as a heatmap
png('data/raw/correlation.png',
    width = 1000,
    height = 2500)

par(mar = c(6, 4, 4, 5) + 0.1)
heatmap(abs(cor))

dev.off()

# get indexes for each covariate (as to which it is highly correlated with)
TCB_SD_idx <- which(abs(cor[,1]) > 0.7)
LSTday_mean <- which(abs(cor[,2]) > 0.7)                           
LSTday_SD <- which(abs(cor[,3]) > 0.7)
LSTnight_mean <- which(abs(cor[,4]) > 0.7)                        
LSTnight_SD <- which(abs(cor[,5]) > 0.7)
TCW_mean <- which(abs(cor[,6]) > 0.7)                               
TCW_SD <- which(abs(cor[,7]) > 0.7)
elevation <- which(abs(cor[,8]) > 0.7)                         
closed_shrublands <- which(abs(cor[,9]) > 0.7)
open_shrublands <- which(abs(cor[,10]) > 0.7)                   
woody_savannas <- which(abs(cor[,11]) > 0.7)
grasslands <- which(abs(cor[,12]) > 0.7)                        
permanent_wetlands <- which(abs(cor[,13]) > 0.7)
croplands <- which(abs(cor[,14]) > 0.7)                        
urban_and_built_up <- which(abs(cor[,15]) > 0.7)
cropland_mosaic <- which(abs(cor[,16]) > 0.7)
barren_or_sparsely_populated <- which(abs(cor[,17]) > 0.7)

##
# output raster stacks as multiband .grd files
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