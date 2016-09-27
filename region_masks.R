## create regional masks for the regional model
## script split study extent into four sections, NE, NW, SE, SW

# clear workspace
rm(list = ls())

# load required package
library(raster)

# read in master mask
master_mask <- raster('data/clean/raster/master_mask.tif')

# create regions based on extent
study_extent <- extent(master_mask)

# specify region one extent
region_one_extent <- study_extent
region_one_extent@ymin <- 19.75675
region_one_extent@xmin <- 108.4201

# specify region two extent
region_two_extent <- study_extent
region_two_extent@ymax <- 19.75675
region_two_extent@xmin <- 108.4201

# specify region three extent
region_three_extent <- study_extent
region_three_extent@ymin <- 19.75675
region_three_extent@xmax <- 108.4201

# specify region four extent
region_four_extent <- study_extent
region_four_extent@ymax <- 19.75675
region_four_extent@xmax <- 108.4201

# create raster masks for each region
region_one <- crop(master_mask, region_one_extent)
region_two <- crop(master_mask, region_two_extent)
region_three <- crop(master_mask, region_three_extent)
region_four <- crop(master_mask, region_four_extent)

plot(region_one)
plot(region_two)
plot(region_three)
plot(region_four)

# write out each of the region mask
writeRaster(region_one,
            file = 'data/raw/raster/regions/region_one',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(region_two,
            file = 'data/raw/raster/regions/region_two',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(region_three,
            file = 'data/raw/raster/regions/region_three',
            format = "GTiff",
            overwrite = TRUE)
writeRaster(region_four,
            file = 'data/raw/raster/regions/region_four',
            format = "GTiff",
            overwrite = TRUE)