## script to download all mosquito genera data from gbif
## data is to be used as background data within the model

# clear workspace
rm(list = ls())

# load required packages
source('code/packages.R')

# read in a list of mosquito genera to download from gbif
genera_list <- read.csv('data/raw/background/gbif_genera_list.csv',
                        stringsAsFactors = FALSE)

list_get <- as.list(genera_list$genera)

# loop through each genera in the list, download, and bind into a single dataframe
genera <- NULL

for(i in 1:length(list_get)){
  
  # get species name
  species_name <- unlist(list_get[i])
  
  # download data from gbif
  downloaded_data <- gbif(species_name, '')
 
  # merge into one dataframe
  if(i == 1){
    
    genera <- downloaded_data
    
  } else {
    
    genera <- rbind.fill(genera,
                         downloaded_data)
  }
  
}

# subset to remove any which are missing coordinates
genera <- genera[!is.na(genera$lat), ]

# reorder and subset gbif data to obtain variables of interest
names(genera)
genera$presence <- rep(NA, nrow(genera))
genera$admin_level <- rep(NA, nrow(genera))
genera$state <- rep(NA, nrow(genera))

genera <- genera[c(12, 92, 92, 157, 81, 53, 58, 159, 109, 56, 56, 30, 158, 96)]

genera$source <- rep('gbif', nrow(genera))

names(genera) <- c('country',
                   'st_year',
                   'end_year',
                   'presence',
                   'species',
                   'lat',
                   'lon',
                   'state',
                   'county',
                   'locality',
                   'sitename',
                   'source_id',
                   'admin_level',
                   'coordinate_uncertainty',
                   'source')

# write out csv
write.csv(genera,
          'data/raw/background/gbif_genera.csv',
          row.names = FALSE)
