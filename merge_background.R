# merge all background datasets so that they have consistent fields
# and contain all necessary fields for modeling process

# clear workspace
rm(list = ls())

# load packages
source('code/packages.R')

# read in each of the different datasets
anopheles <- read.csv('data/raw/background/map_anopheles.csv', stringsAsFactors = FALSE)
aegypti <- read.csv('data/raw/background/kraemer_aegypti.csv', stringsAsFactors = FALSE)
albopictus <- read.csv('data/raw/background/kraemer_albopictus.csv', stringsAsFactors = FALSE)
aedes_gbif <- read.csv('data/raw/background/gbif_aedes.csv', stringsAsFactors = FALSE)
aedes_vect <- read.csv('data/raw/background/vectormap_aedes.csv', stringsAsFactors = FALSE)
culex_gbif <- read.csv('data/raw/background/gbif_culex.csv', stringsAsFactors = FALSE)
culex_vect <- read.csv('data/raw/background/vectormap_culex.csv', stringsAsFactors = FALSE)
anopheles_gbif <- read.csv('data/raw/background/gbif_anopheles.csv', stringsAsFactors = FALSE)
pop_bio <- read.csv('data/raw/background/popbio_all_species.csv', stringsAsFactors = FALSE)
genera <- read.csv('data/raw/background/gbif_genera.csv', stringsAsFactors = FALSE)

# make the names consistent across each dataset, for merging
# main columns to keep are:
# country
# start and end year
# presence/absence
# species
# lat
# long
# locality 
# admin level
# coordinate uncertainty 
# source (gbif, vectormap, map, seeg)

# start with MAP anopheles dataset
names(anopheles)

# create necessary columns
anopheles$state <- rep(NA, nrow(anopheles))
anopheles$county <- rep(NA, nrow(anopheles))
anopheles$locality <- rep(NA, nrow(anopheles))

# subset to get variables of interest, and re-order variables
anopheles <- anopheles[c(2, 9, 11, 8, 7, 3:4, 17:19, 5)]
anopheles$admin_level <- rep(-999, nrow(anopheles))
anopheles$coordinate_uncertainty <- rep(NA, nrow(anopheles))
anopheles$source <- rep('MAP', nrow(anopheles))

# rename fields
names(anopheles) <- c('country',
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
                      'admin_level',
                      'coordinate_uncertainty',
                      'source')

# remove records in anopheles with missing lat/long info
anopheles <- anopheles[!is.na(anopheles$lat), ]

# rbind Moritz aegypti and albopictus 
kraemer <- rbind(aegypti,
                 albopictus)

names(kraemer)

# add missing fields, make NA
kraemer$st_yr <- rep(NA, nrow(kraemer))
kraemer$presence <- rep(1, nrow(kraemer))
kraemer$state <- rep(NA, nrow(kraemer))
kraemer$county <- rep(NA, nrow(kraemer))
kraemer$locality <- rep(NA, nrow(kraemer))

# subset and reorder
kraemer <- kraemer[c(9, 8, 8, 14, 1, 6:7, 15:17, 4, 5)]
kraemer$coordinate_uncertainty <- rep(NA, nrow(kraemer))
kraemer$source <- rep('SEEG', nrow(kraemer))

# rename fields
names(kraemer) <- c('country',
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
                    'admin_level',
                    'coordinate_uncertainty',
                    'source')

# remove records in kraemer with missing lat/long info
kraemer <- kraemer[!is.na(kraemer$lat), ]

# remove separate, raw, kraemer datasets
rm(aegypti,
   albopictus)

# merge the different vectormap datasets as the column names will be consistent 
names(aedes_vect)
aedes_vect$X <- NULL

vect <- rbind(aedes_vect,
              culex_vect)

names(vect)

# generate missing columns
vect$presence <- rep(1, nrow(vect))
vect$admin_level <- rep(NA, nrow(vect))

# reorder and subset vectormap to get variables of interest
vect <- vect[c(45, 79, 79, 84, 30, 40, 43, 46:48, 48, 85, 44)]
vect$source <- rep('Vectormap', nrow(vect))

# rename fields
names(vect) <- c('country',
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
                 'admin_level',
                 'coordinate_uncertainty',
                 'source')

# remove vectormap records missing lat/long info
vect <- vect[!is.na(vect$lat), ]

# remove the vectormap raw, separate datasets
rm(aedes_vect,
   culex_vect)

# merge the different gbif datasets as the column names will be consistent
gbif <- rbind.fill(aedes_gbif,
                   anopheles_gbif,
                   culex_gbif)

names(gbif)

# add missing fields
gbif$presence <- rep(NA, nrow(gbif))
gbif$admin_level <- rep(NA, nrow(gbif))
gbif$state <- rep(NA, nrow(gbif))

# reorder and subset gbif data to obtain variables of interest
gbif <- gbif[c(19, 134, 134, 154, 116, 76, 83, 156, 86,  79, 79, 155, 18)]
gbif$source <- rep('gbif', nrow(gbif))

# rename for consistency
names(gbif) <- c('country',
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
                 'admin_level',
                 'coordinate_uncertainty',
                 'source')

# remove gbif records missing lat/long information
gbif <- gbif[!is.na(gbif$lat), ]

# remove individual, raw gbif dataframes
rm(aedes_gbif,
   anopheles_gbif,
   culex_gbif)

# handle pop_bio data
names(pop_bio)

# create start year, by taking the first 4 digits in the collection.date.range column
substring <- substr(pop_bio$Collection.date.range, 0, 4)
pop_bio$start_year <- substring
pop_bio$country <- rep(NA, nrow(pop_bio))
pop_bio$presence <- rep(1, nrow(pop_bio))
pop_bio$state <- rep(NA, nrow(pop_bio))
pop_bio$county <- rep(NA, nrow(pop_bio))
pop_bio$locality <- rep(NA, nrow(pop_bio))
pop_bio$coordinate_uncertainty <- rep(NA, nrow(pop_bio))
pop_bio$source <- rep('Popbio', nrow(pop_bio))

# as this is messy data, assign end year equal to start year
pop_bio <- pop_bio[c(17, 16, 16, 18, 3, 10, 11, 19:21, 12, 13, 22:23)]

names(pop_bio) <- c('country',
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
                    'admin_level',
                    'coordinate_uncertainty',
                    'source')

# combine the different sources of background data
stopifnot(all.equal(colnames(anopheles), colnames(vect), colnames(gbif), colnames(kraemer), colnames(pop_bio)))
background <- rbind(anopheles,
                    vect,
                    gbif,
                    kraemer,
                    pop_bio,
                    genera)  

rm(anopheles,
   vect,
   gbif,
   kraemer,
   pop_bio,
   genera)

unique(background$species)

# remove any na lat/long records
background <- background[!is.na(background$lat), ]

# duplicate background incase need to revert to previous versions
back_dup <- background
background <- back_dup

# remove tritaeniorhynchus records (in the popbio dataset, something like 5 records)
background <- background[!background$species =='Culex tritaeniorhynchus', ]

# correct SEEG years for china
background$st_year[background$st_year == '2006-2008'] <- 2006
background$end_year[background$end_year == '2006-2008'] <- 2008
background$st_year[background$st_year == 'No data'] <- NA
background$end_year[background$end_year == 'No data'] <- NA

# clean the data a little before writing to disk
# change coordinate uncertainty from m into km
# get a list of the unique coordinate uncertainties; check that they all appear to be in m
unique(background$coordinate_uncertainty)

# divide by 1000 to convert from m into km
background$coordinate_uncertainty <- background$coordinate_uncertainty/1000

# change any locations which have less than 5km uncertainty into NA, as these will be treated as a point
background$coordinate_uncertainty[background$coordinate_uncertainty <5] <- NA

# admin levels need adding to the datasets; but is present for some of the aedes data
# change points to -999, and change the 'less than 100km', 'less than 25km' and 'less than 10km' 
# into a numeric in the coordinate uncertainty column
unique(background$admin_level)

# add numerics to the coordinate uncertainty columns for the non-point aedes locs
background$coordinate_uncertainty[background$admin_level == 'Less than 100km'] <- 100
background$coordinate_uncertainty[background$admin_level == 'Less than 25km'] <- 25
background$coordinate_uncertainty[background$admin_level == 'Less than 10km'] <- 10

# now modify what is in the admin level column, based on the text
background$admin_level <- ifelse(background$admin_level == 'Less than 100km', 
                                 -999, background$admin_level)
background$admin_level <- ifelse(background$admin_level == 'Less than 25km', 
                                 -999, background$admin_level)
background$admin_level <- ifelse(background$admin_level == 'Less than 10km', 
                                 -999, background$admin_level)
background$admin_level <- ifelse(is.na(background$admin_level), 
                                 -999, background$admin_level)

background$presence <- rep(1, nrow(background))

# write out the clean(ish) dataset to disk
write.csv(background,
          'data/raw/background/merged_global.csv',
          row.names = FALSE)

