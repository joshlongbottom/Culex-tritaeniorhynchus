## script to run vector niche model
## clear workspace
rm(list = ls())

# load in packages 
source('code/packages.R')

# load bespoke functions file
source('code/functions_culex.R')

# set the RNG seed
set.seed(1)

# set output path
outpath <- 'output/vectors/'

# load the data
# raster covariates
covs_current <- brick('data/clean/raster/raster_current.grd')
covs_temporal <- brick('data/clean/raster/raster_temporal.grd')
covs_nontemporal <- brick('data/clean/raster/raster_nontemporal.grd')

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
names(covs_current)[names(covs_current)=='croplands_2012']<-'croplands'

# load in occurrence data
vector_dat <- read.csv('data/clean/occurrence/expanded_culex_data_03102016.csv',
                        stringsAsFactors =FALSE)

# load in background data
bias <- read.csv('data/clean/background/point_background_data_06102016.csv',
                 stringsAsFactors = FALSE)

# add geometry type column to bias dataset
names(bias)[14] <- 'Geometry_type'

# rename vector_dat unique_ID column
names(vector_dat)[1] <- "Unique_ID"
names(bias)[16] <- "Unique_ID"

# loop through these species fitting models
for (species in c('vector_dat')) {
  
  # get occcurrence data for this species
  occ <- get(species)
    
  # only use presence points 
  occ <- subset(occ, occ$presence=='presence')
  
  # set output path for this species
  outpath_species <- paste0(outpath,
                            species,
                            '/')
  
  # create the directory if it doesn't already exist
  if (!file.exists(outpath_species)) {
    dir.create(outpath_species)
  }

  # combine the occurrence and background records
  dat <- rbind(cbind(PA = rep(1, nrow(occ)),
                     wt = rep(1, nrow(occ)),
                     occ[, c('lon', 'lat', 'Year', 'Unique_ID', 'Geometry_type')]),
               cbind(PA = rep(0, nrow(bias)),
                     wt = rep(0, nrow(bias)),
                     bias[ ,c('lon', 'lat', 'Year', 'Unique_ID', 'Geometry_type')]))
  
  # create an empty dataframe
  dat_covs <- extract(covs_current, dat[, c('lon', 'lat')])
  
  dat_covs[] <- NA
  
  # loop through extracting covs for each year
  for (year in 2001:2012) {
    
    # truncate years to the ones we have covariates for
    years <- dat$Year
    years <- pmax(years, 2001)
    years <- pmin(years, 2012)
    
    # index for this year's data
    idx <- which(years == year)
    
    # covs for this year
    # get index for temporal covariates for relevant year  
    idx2 <- which(substr(names(covs_temporal), nchar(names(covs_temporal)) - 3, nchar(names(covs_temporal)))==year)
    
    covs_year <- covs_temporal[[idx2]]
    names(covs_year)[names(covs_year)==paste0('closed_shrublands_', year)]<-'closed_shrublands'
    names(covs_year)[names(covs_year)==paste0('open_shrublands_', year)]<-'open_shrublands'
    names(covs_year)[names(covs_year)==paste0('woody_savannas_', year)]<-'woody_savannas'
    names(covs_year)[names(covs_year)==paste0('grasslands_', year)]<-'grasslands'
    names(covs_year)[names(covs_year)==paste0('permanent_wetlands_', year)]<-'permanent_wetlands'
    names(covs_year)[names(covs_year)==paste0('urban_and_built_up_', year)]<-'urban_and_built_up'
    names(covs_year)[names(covs_year)==paste0('cropland_natural_vegetation_mosaic_', year)]<-'cropland_natural_vegetation_mosaic'
    names(covs_year)[names(covs_year)==paste0('barren_or_sparsely_populated_', year)]<-'barren_or_sparsely_populated'
    names(covs_year)[names(covs_year)==paste0('croplands_', year)]<-'croplands'
    
    # add nontemporal covariates
    covs_year <- addLayer(covs_year, covs_nontemporal)
    
    # extract covariate data
    covs_year_extract <- extract(covs_year, dat[idx, c('lon', 'lat')])
    
    # check they're all there
    stopifnot(all(colnames(dat_covs) %in% colnames(covs_year_extract)))
    
    # match up the column names so they're in the right order
    match <- match(colnames(dat_covs), colnames(covs_year_extract))
    
    # extract covariates for all points
    dat_covs[idx, ] <- covs_year_extract[, match]
    
  } 
  
  # combine covariates with the other info
  dat_all <- cbind(dat, dat_covs)
  
  # which rows in dat_covs contain an NA
  outside_idx <- attr(na.omit(dat_covs), 'na.action')

  # create a dataframe of records which are NAs
  dat_nas <- dat_all[outside_idx, ]
  
  if (!is.null(outside_idx)) {
    # remove these from dat_all
    # this step removes two points from anopheles_bias dataset which fall within the extent but off land
    dat_all <- dat_all[-outside_idx, ] 
  
    }
  
  # specify the number of cores (ncpu), and number of boostraps (nboot)
  ncpu <- 60
  nboot <- 300
  
  # get random bootstraps of the data (minimum 30 pres/30 abs)
  # for new subsample poly script, we require "Geometry_type" field, which is
  # removed in the previous "sorting_polygons_culex" script
  warning("check that geometry type is in the dataset, otherwise subsamplePolys won't run!")
  
  data_list <- replicate(nboot,
                         subsamplePolys(dat_all,
                                        replace = TRUE,
                                        minimum = c(30, 30)),
                         simplify = FALSE)

  # initialize the cluster
  sfInit(parallel = TRUE, cpus = ncpu)
  sfLibrary(seegSDM)
  
  # make sure you check the column indexes in runBRT below! I've added new weighting
  # columns so make sure that they are the right indexes, especially the covar indexes
  
  model_list <- sfLapply(data_list,
                         runBRT,
                         gbm.x = 8:ncol(dat_all),
                         gbm.y = 1,
                         n.folds = 10,
                         pred.raster = covs_current,
                         gbm.coords = 3:4,
                         # check index for weight column before running runBRT
                         wt = function(PA) ifelse(PA == 1, 1, sum(PA) / sum(1 - PA)))
  
  # get cv statistics in parallel
  stat_lis <- sfLapply(model_list, getStats)
  
  # summarise all the ensembles
  preds <- stack(lapply(model_list, '[[', 4))
  
  # summarise the predictions in parallel
  preds_sry <- combinePreds(preds, parallel = TRUE)
  
  # stop the cluster
  sfStop()
  
  # convert the stats list into a matrix using the do.call function
  stats <- do.call("rbind", stat_lis)
  
  # save them
  write.csv(stats,
            paste0(outpath_species,
                   'stats.csv'))
  
  names(preds_sry) <- c('mean',
                        'median',
                        'lowerCI',
                        'upperCI')
  
  # save the prediction summary
  writeRaster(preds_sry,
              file = paste0(outpath_species,
                            species),
              format = 'GTiff',
              overwrite = TRUE)
  
  # save the relative influence scores
  relinf <- getRelInf(model_list)
  
  write.csv(relinf,
            file = paste0(outpath_species,
                          'relative_influence.csv'))
  
  # plot and the marginal effect curves
  png(paste0(outpath_species,
             'effects.png'),
      width = 2000,
      height = 2500,
      pointsize = 30)
  
  par(mfrow = n2mfrow(nlayers(covs_current)))
  
  effects <- getEffectPlots(model_list,
                            plot = TRUE)
  
  dev.off()
  
  # plot the risk map
  png(paste0(outpath_species,
             'prediction_mean.png'),
      width = 2000,
      height = 2000,
      pointsize = 30)
  
  par(oma = rep(0, 4),
      mar = c(0, 0, 0, 2))
  
  plot(preds_sry[[1]],
       axes = FALSE,
       box = FALSE)
  
  points(dat[dat$PA == 1, 3:4],
         pch = 16,
         cex = 1,
         col = 'blue')
  
  dev.off()
  
}
