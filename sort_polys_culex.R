# prepare culex occurrence data for modelling
# check all packages are loaded before running (if working on script separately)

# clear workspace
rm(list = ls())

# load packages
library(seegSDM)
library(raster)
library(snowfall)
library(GRaF)
library(sp)
library(rgeos)
library(maptools)
library(maps)
library(dismo)

# load data
# raw occurrence data
dat <- read.csv('data/raw/datasets/merged_datasets_26082016.csv',
                      stringsAsFactors = FALSE)

# use occurrence data only
dat <- subset(dat, dat$presence=="presence")

# load matching rasters for polygons
poly1 <- brick('data/clean/raster/polygon_rasters/admin1_raster.flt')
poly2 <- brick('data/clean/raster/polygon_rasters/admin2_raster.flt')
poly3 <- brick('data/clean/raster/polygon_rasters/admin3_raster.tif')

# load a 5km template raster of the study area extent
template <- raster('data/clean/raster/raster.grd')

# crop admin rasters to extent
poly1 <- crop(poly1, template)
poly2 <- crop(poly2, template)
poly3 <- crop(poly3, template)

# temporal standardisation
# create dataset named occurrence
occurrence <- dat

# change colnames of occurrence to match those required for tempStand
names(occurrence)
names(occurrence)[10] <- "Start_Year"
names(occurrence)[12] <- "End_Year"
names(occurrence)[7] <- "Admin"
names(occurrence)[3] <- "Latitude"
names(occurrence)[4] <- "Longitude"
names(occurrence)[20] <- "GAUL"
names(occurrence)[1] <- "SourceID"

# create raster stack for admin level data
admin <- stack(poly1,
               poly2,
               poly3)

# create dataframe of NA dates
no_date_occurrence <- occurrence[which(is.na(occurrence$Start_Year)), ]

# subset to remove NA dates
occurrence <- occurrence[which(!(is.na(occurrence$Start_Year))), ]
occurrence <- occurrence[which(!(is.na(occurrence$End_Year))), ]

# run temporal standardisation
dups <- tempStand(occurrence, admin, verbose = TRUE)

# create dataframes/vectors for duplicate rows
dup_occ <- as.data.frame(dups$occurrence)
dup_polys <- as.vector(dups$duplicated_polygons)
dup_points <- as.vector(dups$duplicated_points)

# create subset without these duplicated polygons
# create index to match duplicate polygon records
poly_idx <- match(dup_polys, dup_occ$UniqueID)

# create new dataframe minus the duplicated index
non_dup_poly <- dup_occ[-poly_idx, ]

# create index to match duplicated point records
point_idx <- match(dup_points, non_dup_poly$UniqueID)

# create new dataframe minus the duplicated index
non_duplicated_occ <- non_dup_poly[-point_idx, ]

# clear workspace a little
rm(non_dup_poly,
   dup_points,
   dup_polys, 
   dup_occ,
   occurrence)

names(non_duplicated_occ)

# change back colnames to match original input format
names(non_duplicated_occ)[1] <- "unique_id"
names(non_duplicated_occ)[3] <- "lat"
names(non_duplicated_occ)[4] <- "lon"
names(non_duplicated_occ)[7] <- "admin_level"
names(non_duplicated_occ)[18] <- "GAUL_CODE"
names(non_duplicated_occ)[21] <- "temp_standID"

names(no_date_occurrence)
no_date_occurrence$Start_Year <- NULL
no_date_occurrence$End_Year <- NULL
no_date_occurrence$Year <- rep(NA, nrow(no_date_occurrence))
no_date_occurrence$temp_standID <- rep(NA, nrow(no_date_occurrence))
names(no_date_occurrence)[1] <- "unique_id"
names(no_date_occurrence)[3] <- "lat"
names(no_date_occurrence)[4] <- "lon"
names(no_date_occurrence)[7] <- "admin_level"
names(no_date_occurrence)[18] <- "GAUL_CODE"
names(no_date_occurrence)[21] <- "temp_standID"

stopifnot(all.equal(colnames(non_duplicated_occ), colnames(no_date_occurrence)))
occurrence <- rbind(non_duplicated_occ,
                    no_date_occurrence)

# write out non_duplicated presence dataset
write.csv(occurrence,
          'data/raw/datasets/occurrence_temp_stand_26082016_prepolyextension.csv')

# some culex data points have missing values (NA) for'year' (97 records 02.07.2016)
# make an index of data points with and without NA for year
NA_year_idx <- which(is.na(occurrence$Year))

year_idx <- which(!(is.na(occurrence$Year)))

x <- occurrence[year_idx, 'Year'] 

# sample from distribution of years within data set
# set seed
set.seed(1)

years <- sample(x, size=length(NA_year_idx), replace=TRUE)

# replace NAs with year by sampling from distribution of years within data set
for (i in 1:length(NA_year_idx)) {
  
  occurrence[NA_year_idx[[i]], 'Year']<- years [[i]]
  
}

# create data subset of only points
# (expanded polys will be merged onto this; but we also want a separate frame which has
# non-admin polys, so we don't loose those within the expanded dataset)
dat_new <- subset(occurrence, occurrence$location_type == 'point')

# split to get a 'non-admin-polys'
dat_non_poly <- subset(occurrence, occurrence$location_type == 'non-admin-poly')

# subset the occurrence data into polygons
poly1_dat <- subset(occurrence, occurrence$admin_level=='1')

poly2_dat <- subset(occurrence, occurrence$admin_level=='2')

poly3_dat <- subset(occurrence, occurrence$admin_level=='3')

# create empty dataframe for excluded polygons to populate
excluded_polys <- dat_new[,colnames(dat_new)][0,]

# ~~~~~~~~~~~
# sample random points from within polygons on a 5km grid
for (polygon in c('poly1_dat', 'poly2_dat', 'poly3_dat')){
  
  # get data subset for polygon
  poly_dat <- get(polygon)
  
  for (i in 1:nrow(poly_dat)){
    
    # get polygon code from dataset
    
    if (polygon %in% c('poly1_dat','poly2_dat','poly3_dat')) {
        
    polycode <- poly_dat$GAUL_CODE[i]
        
    } else {
    
      }  
    
    # get raster for this polygon
    substring <- substr(polygon, 0, 5)
    raster <- get(substring)
    
    # obtain index for pixels in raster with this identifier 
    idx <- which(getValues(raster)==polycode)
    
    # get coordinates of the cells there
    pts <- xyFromCell(raster, idx)
    
    # the number of points
    n <- nrow(pts)
    
    # for polygons less than 1000 pixels
    if (!(n > 1000)){
    
    # if its larger than 100, pick 100 of them at random
    if (n>100){
      
      pts<- pts[sample(1:n, size = 100, replace=TRUE),]
      
      n <- 100
    
      }
    
    # pull out the info for that record
    info_mat <- poly_dat[rep(i, nrow(pts)),]
    
    # stick the coordinates in
    info_mat[,c('lat', 'lon')] <- pts[,2:1]
    
    # append it to new_dat
    dat_new <- rbind(dat_new, info_mat)
    
    } else {
      
      # polygon is greater than 1000 pixels, therefore, we're going
      # to exlucde. pull out the info for that record
      info_mat_ex <- poly_dat[rep(i, nrow(pts)),]
      
      # and add polygon info to excluded polygons dataframe
      excluded_polys <- rbind(excluded_polys, info_mat_ex)
      
    }
}
}

# now we need to expand the 'non-admin polys' using the 'buffer' column
# load in bespoke function
source('code/functions_culex.R')

# set projection of template
projection(template) <- '+init=epsg:3395'  

# get coordinates for pixels within each bespoke polygon
non_poly <- getPolygonPixels(template, 
                             dat_non_poly, 
                             4:3, 
                             19)

# have a look at average number of pixels for buffer extrapolations
# get a unique pixel count for each unique_id
pixel_stats <- unique(non_poly[c("unique_id", "pixel_stats")])

# get sum of number of pixels; sum - non_poly = number outside mask
sum(pixel_stats$pixel_stats, na.rm = TRUE)
# NA outside of mask!

# with sorting_polygons script, polygons >100 pixels had a random sample of 100 pixels
# some bespoke polys have >100 pixels, script below subsamples 100 pixels from these 
# large polygons

# subset poly dataset into large polys, and polys to keep
large_polys <- non_poly[which(non_poly$pixel_stats >100), ]
keep_polys <- non_poly[which(!non_poly$pixel_stats >100), ]

id_list <- unique(large_polys$unique_id)

# loop through large polys and select 100 pixels, with replacement
for(i in 1:length(id_list)){
  
  id <- id_list[i]
  
  poly <- large_polys[which(large_polys$unique_id == id), ]
  
  n <- nrow(poly)
  
  if (n>100){
    
    subset_poly <- poly[sample(1:n, size = 100, replace=TRUE),]
    
  }
  
  subset_poly$pixel_stats <- 100
  
  keep_polys <- rbind(keep_polys,
                      subset_poly)
  
}

# rebind all data: points, expanded polys and expanded non-admin polys
# first drop the pixel stats column in 'keep polys' dataframe
keep_polys$pixel_stats <- NULL

# now merge datasets into one
all_expanded <- rbind(dat_new,
                      keep_polys)

# change name of 'location_type' column to match that in subsamplePolys
names(all_expanded)[6] <- "Geometry_type"

# change 'non-admin poly' in geometry_type to 'polygon' for use in subsamplePolys 
all_expanded$Geometry_type <- gsub("^non-admin-poly$", 'polygon', all_expanded$Geometry_type)

# plot the data to check that the random sampling within polygons, and buffer expansion
# has worked as envisaged
plot(poly1)
points(all_expanded$lon, all_expanded$lat, col = "red", pch = 16, cex = 0.6)

# if the resulting dataset looks fairly clean, write it to disk
if (!(any(is.na(all_expanded$lat)))) {
  # output the resulting table
  write.csv(all_expanded,
            file = 'data/clean/occurrence/expanded_culex_data_26082016.csv',
            row.names = FALSE)
}  

# create unique list of excluded polygons
excluded_list <- unique(excluded_polys[c("unique_id", "country", "admin_level", "GAUL_CODE")])

# write out excluded polys
write.csv(excluded_list,
          'data/clean/occurrence/excluded_polygons_26082016.csv')


