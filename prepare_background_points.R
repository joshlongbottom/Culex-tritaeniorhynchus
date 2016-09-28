## script to prepare background data for the model

## script contains numerous sections:
## section 1) trims the data to the extent of the model
## section 2) gets country ISO codes (for those data missing country IDs)
## section 3) removes records below the wallace line
## section 4) remove duplicate point data and drop all polygon data

# clear workspace
rm(list = ls())

# load required packages
source('code/packages.R')

# set the seed for random sampling
set.seed(1)

# read in merged mosquito species background dataset
background <- read.csv('data/raw/background/merged_global.csv',
                       stringsAsFactors = FALSE)

# read in extent shapefile
study_area <- shapefile('data/raw/extent/culex_extent_rawv2.shp')

# get extent of study area
extent(study_area)

#### 1) trim background to only contain records within extent ####
background <- background[background$lat > -14.05944, ]
background <- background[background$lat < 53.57295, ]
background <- background[background$lon > 60.87297, ]
background <- background[background$lon < 155.9672, ]

# remove any records which are missing coordinates (longitude field used here)
background <- background[(!is.na(background$lon)), ]

# plot trimmed data to check occ distribution
plot(study_area)
points(background$lon, background$lat, pch = 16, cex = 0.5, col = "blue")

#### 2) get country codes for popbio data missing country id's ####
# read in admin 0 shapefile
country <- shapefile('data/raw/shape/admin2013_0.shp')

# create matrix of point locations
lat <- background$lat
long <- background$lon

pts <- cbind(long,
             lat)

# using the sp package, where country is the admin 0 shapefile and pts 
# is a two-column (long, lat) matrix of coordinates:
pts_sp <- SpatialPoints(pts,
                        proj4string = CRS(projection(country)))

# get ISO codes for all points
iso <- over(pts_sp, country)$COUNTRY_ID

# merge back with background dataset
background$iso <- iso

#### 3) countries assigned an NA for iso are assummed to fall off of land ####
# remove these records, alongside records for PNG and AUS
background <- background[!is.na(background$iso), ]
background <- background[!background$iso == "PNG", ]
background <- background[!background$iso == "AUS", ]

#### 4) remove duplicate point data and drop all polygon data ####
background$admin_level[!is.na(background$coordinate_uncertainty)] <- 'buffer'

# subset and create datasets based on admin level
admin_1 <- background[background$admin_level == 1, ]
admin_2 <- background[background$admin_level == 2, ]
buffer <- background[background$admin_level == 'buffer', ]
points <- background[background$admin_level == -999, ]

## due to uncertainty, we only want to keep the point data
# add location_type indicator
points$location_type <- 'point'

# write out merged extent background (pre-de-duplication)
write.csv(background,
          'data/raw/background/points_extent.csv',
          row.names = FALSE)

#### remove spatially and temporally duplicated point data ####
# make NA GAUL_CODE columns for point locs
points$GAUL_CODE <- NA

# read in raster
template <- raster('data/clean/raster/master_mask.tif')

# create dataframe of NA dates
no_date_points <- points[which(is.na(points$st_year)), ]

# subset to remove NA dates
points_dup <- points[which(!(is.na(points$st_year))), ]
points_dup <- points[which(!(is.na(points$end_year))), ]

# grab cell numbers from master mask layer
nums <- cellFromXY(template, points_dup[7:6])

# bind cell numbers with end year, index to which are duplicated, which aren't
nums <- data.frame(nums)

points_dup_cells <- cbind(points_dup, 
                          nums)

points_dup_cells$dup_id <- paste(points_dup_cells$nums, points_dup_cells$end_year, sep = " ")

points_dup_cells$duplicated_points <- duplicated(points_dup_cells$dup_id)

# create de-duped subset
points_deduped <- points_dup_cells[which(points_dup_cells$duplicated_points == "FALSE"), ]

# remove those which didn't have a cell value as outside extent
points_deduped <- points_deduped[which(!(is.na(points_deduped$nums))), ]

# generate a unique id for the background records
points_deduped$unique_id <- 1:nrow(points_deduped)
points_deduped$unique_id <- (points_deduped$unique_id + 99900)

# drop start year column
no_date_points$st_year <- NULL
points_deduped$st_year <- NULL

# rename end year to 'Year' (for backround data spanning numerous years, end year is assigned here)
names(points_deduped)[2] <- "Year"
names(no_date_points)[2] <- "Year"

# drop unnecessary cols (nums, dup_id, duplicated_point)
points_deduped$nums <- NULL
points_deduped$dup_id <- NULL
points_deduped$duplicated_points <- NULL

# generate a unique id for the background records with no year vals
no_date_points$unique_id <- 1:nrow(no_date_points)
no_date_points$unique_id <- ((no_date_points$unique_id)+120000)

# bind the datasets back together
stopifnot(all.equal(colnames(no_date_points), colnames(points_deduped)))

de_duplicated_points <- rbind(points_deduped,
                              no_date_points)

# some data points have missing values (NA) for'year'
# make an index of data points with and without NA for year
NA_year_idx <- which(is.na(de_duplicated_points$Year))

year_idx <- which(!(is.na(de_duplicated_points$Year)))

x <- de_duplicated_points[year_idx, 'Year'] 

# sample from distribution of years within data set
years <- sample(x, size=length(NA_year_idx), replace=TRUE)

# replace NAs with year by sampling from distribution of years within data set
for (i in 1:length(NA_year_idx)) {
  
  de_duplicated_points[NA_year_idx[[i]], 'Year']<- years [[i]]
  
}

# as we're now only using the point dataset, drop coord uncertainty column
de_duplicated_points$coordinate_uncertainty <- NULL

# write out de-duplicated, point only dataset
write.csv(de_duplicated_points,
          file = 'data/clean/background/point_background_data_17082016.csv',
          row.names = FALSE)
