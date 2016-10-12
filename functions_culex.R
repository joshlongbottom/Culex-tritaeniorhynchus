### function for sampling data containing polygon, sampling from the unique_ID column

subsamplePolys <- function (data, ...) {
  # given a presence-background dataset, with multiple rows for some of the
  # occurrence records, subset it so that there's only one randomly selected
  # point from each polygon and then take a bootstrap it using `subsample`.
  # Dots argument is passed to subsample.
  
  # get the point data
  point_dat <- subset(data, data$Geometry_type!='polygon') 
  
  # subset to get polygon data only
  poly_dat <- subset(data, data$Geometry_type=='polygon')
  
  if (nrow(poly_dat) > 0) {
    
    # get the different IDs
    u <- unique(poly_dat$Unique_ID)
  
    # remove the NA values
    u <- u[!is.na(u)]
  
    # loop through, picking an index for each based on the number available
    data_idx <- sapply(u,
                     function (identifier, data) {
                       idx <- which(data$Unique_ID == identifier)
                       sample(idx, 1)
                     },
                     data)
  
    # get the subsetted dataset
    dat <- data[data_idx, ]
    
    # append the subsetted polygon data to the point data
    point_dat <- rbind(dat, point_dat)
  
  }

  # randomly subsample the dataset
  ans <- subsample(point_dat,
                   n = nrow(point_dat),
                   ...)
                    
  # remove the polygon columns
  #ans <- subset(ans, select= -c(Geometry_type, Polygon_code, Gaul_code))
  
  return (ans)

}

insideMask <- function(points, mask){
  
  # checks whether lats/longs fall on non-missing pixels of a raster 
  # takes two arguments: points, a dataframe containing columns named 'Longitude' and 'Latitude' 
  # mask is a raster 
  # returns a dataframe containing only those rows with points falling on non-missing pixels
  # if all points fall on missing pixels, the function throws an error
  
  # check whether arguments are in the correct format
  stopifnot(inherits(mask, 'Raster'))
  stopifnot(inherits(points, 'data.frame'))
  
  # get indexes of points which fall inside the mask
  inside_idx <- which(!(is.na(extract(mask, points[,c('Longitude', 'Latitude')]))))
  
  # subset these points
  inside_points <- points[inside_idx, ]
  
  # if raster values exist for one point or more, return the point/s, otherwise throw an error 
  if (nrow(inside_points)==0) {stop('all points outside mask')}
  
  return (inside_points)
  
}

getPolygonPixels <- function (template, 
                              data,
                              coords,
                              width) {
  
  # function that takes a raster object and a dataframe 
  # containing at least polygon centroid coordinates and width
  # and returns a dataframe with a row for each raster pixel 
  # contained within the polygon area
  # template = raster at correct pixel resolution
  # data = dataframe 
  # coords = column index for polygon centroid coordinates, longitude then latitude
  # width = column index for polygon width (in kilometres)
  # NB: dataframe must contain a unique_ID column for result to be used 
  # in functions like subsamplePolys etc.
  
  # packages needed
  require(sp)
  require(rgeos)
  
  # subset the polygon and point data
  # polygon index
  poly_idx <- which(!(is.na(data[,width])))
  
  data_poly <- data[poly_idx,]
  data_point <- data[-poly_idx,]
  data_point$pixel_stats <- rep(NA, nrow(data_point))
  
  for (i in 1:nrow(data_poly)) {
    
    message(paste('processing point', i, 'of', nrow(data_poly)))
    
    # get the polygon size
    poly_size <- data_poly[i, width]
    
    # get the centroid coords
    pt <- data_poly[i, coords]
    
    # calculate circle radius
    radius <- poly_size/2
    
    # convert to decimal degrees at the equator
    radius <- radius / 111.2
    
    # turn coords into SpatialPoints
    spts <- SpatialPoints(pt,
                          CRS(proj4string(template)))
    
    # turn SpatialPoints into SpatialPolygons circles
    spts_circle <- gBuffer(spts, width = radius)
    
    # extract cell IDs within these polygon
    extract_info <- extract(template, spts_circle, cellnumbers=TRUE)
    
    # unlist
    extract_info <- extract_info[[1]]
    
    # get cell IDs
    cells <- extract_info[,1]
    
    # get coordinates of the cells 
    new_pts <- xyFromCell(template, cells)
    
    # set number of new rows
    n <- length(cells)
    
    # pull out the info for that records and repeat n times
    new_rows <- data_poly[rep(i, n),]
    
    # stick the new lats/longs in
    new_rows[, coords] <- new_pts
    
    # return the number of pixels extrapolated to in new column "pixel_stats"
    new_rows$pixel_stats <- rep(n, nrow(new_rows))
    
    # make new_pts into a data.frame with columns named 'Longitude' and 'Latitude'
    # to use with insideMask function
    new_pts <- as.data.frame(new_pts)
    names(new_pts) <- c("Longitude", 
                        "Latitude")
    
    # check that new points are within covariate mask
    new_pts <- insideMask(new_pts, template)
    
    # append it to dat_new
    data_point <- rbind(data_point, 
                        new_rows)
    
  }    
  
  return (data_point)
  
}

balanceWeights <- function(data) {
  # given a mixed spatial data frame of presence, true absence and pseudo-absence data, ensure the 
  # sum of the weights of the presences and true absences plus pseudo-absences are balanced
  
  # subset 'true' presences and absences
  true_dat <- data[data$true==1,]
  
  # sum weight of presences
  presence_total <- sum(true_dat[true_dat$PA==1,]$wt)
  
  # sum weight of absences (true and pseudo) 
  absence_total <- sum(true_dat[true_dat$PA==0,]$wt) + sum(data[data$true==0,]$wt)
  
  # replace pseudo weights with new balanced weight
  data[data$true==0, 'wt'] <- data[data$true==0,]$wt * (presence_total/absence_total)
  
  return(data)
  
}

# function to calculate the mean and standard deviation for each pixel across bootstraps
combine2 <- function(x){
  
  ans <- c(mean=mean(x), 
           sd=sd(x))
  
  return(ans)
}

