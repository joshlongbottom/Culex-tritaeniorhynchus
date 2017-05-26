# Culex
Code from the *Culex tritaeniorhynchus* BRT distribution mapping project "Mapping the spatial distribution of the Japanese encephalitis vector, Culex tritaeniorhynchus Giles, 1901 (Diptera: Culicidae) within areas of Japanese encephalitis risk"
(https://parasitesandvectors.biomedcentral.com/articles/10.1186/s13071-017-2086-8)

## Description
We assembled a contemporary database of *Cx. tritaeniorhynchus* presence records within Japanese encephalitis risk areas from formal literature and other relevant resources, resulting in 1,045 geo-referenced, spatially and temporally unique presence records spanning from 1928 to 2014 (71.9% of records obtained between 2001 and 2014). These presence data were combined with a background dataset capturing sample bias in our presence dataset, along with environmental and socio-economic covariates, to inform a boosted regression tree model predicting environmental suitability for *Cx. tritaeniorhynchus* at each 5 × 5 km gridded cell within areas of JE risk. The resulting fine-scale map highlights areas of high environmental suitability for this species across India, Nepal and China that coincide with areas of high JE incidence, emphasising the role of this vector in disease transmission and the utility of the map generated.

## Project workflow

1. **sort_rasters_culex.R**: This script prepares the covariate surfaces used in the boosted regression tree model. The script trims a stack of the global rasters by the study extent, based on a shapefile defining the extent of the model area. The seegSDM function 'masterMask' loops through each of the covariate layers, finds pixels with NA covariate values, and masks the whole stack by these NA pixels. Covariate surfaces are then partitioned into three stacks; 1 - current covariates (2012 surfaces), 2 - temporal covariates (2001 - 2012), and 3 - non-temporal covariates (covariates which are synoptic, such as daytime temperature, and elevation).

2. **sort_polys_culex.R**: This script prepares polygon data, prior to modelling. Administrative polygons (areas >5 km wide [5 km cells are the modelled resolution]), are sampled using a Monte Carlo simulation, to produce a maximum of 100 cells per polygon. For example, an administrative polygon, which is 80 km wide, is sampled (with replacement), to produce 100 rows of data, containing the central latitude and longitude for a random 5 km cell.
Data without a sampling year are also assigned a sampling year based on the distribution of sampling years across the whole dataset. This year data is used in the run_culex.R script to assign reference points the appropriate covariate values.

3. **run_culex.R**: This script implements the boosted regression tree model. Requirements for this script include: 
	- an input dataframe of species occurrence data 
	- an input dataframe of species background data (Philips et al. 2009 - https://www.ncbi.nlm.nih.gov/pubmed/19323182) 
	- each of the covariate stacks produced during the 'sort_rasters_culex.R' script.

This script combines the presence and absence datasets, and extracts the covariate values for each reference point (presence/absence). This covariate extraction step incorporates sampling year, to assign covariates values relative to the year of sampling. For example, occurrence and background records obtained between the years 2001 and 2012 were assigned their respective annual covariate value (i.e. 2008 occurence data is assigned 2008 land cover values). Data points as the result of sampling before 2001 are assigned 2001 covariate values, and data points which are the result of sampling after 2012 are assigned the 2012 covariate values.
This script then proceeds to generate *n* random bootstraps of the presence/absence data - these bootstraps will form the data used in *n* submodels. Once a list of bootstrapped data has been defined, the script then proceeds to create a model list, which is a list of the outputs of *n* boosted regression tree (BRT) submodels. Each BRT submodel is generated using the 'runBRT' function in the seegSDM package, specifying the number of folds for cross validation.
Once all of the submodels have been ran, the script then proceeds to summarise all of the submodels, creating an ensemble. This ensemble model is then used to predict the suitability for *Culex tritaeniorhynchus* at each 5 km<sup>2</sup> pixel within the study extent. Summary statistics for the model are also generated, including: (i) AUC; (ii) Kappa statistic; (iii) sensitivity; (iv) specificity; and (v) PCC.


![Alt text](http://media.springernature.com/full/springer-static/image/art%3A10.1186%2Fs13071-017-2086-8/MediaObjects/13071_2017_2086_Fig1_HTML.gif "Overview of the methods")

Overview of the methods. White boxes describe a data process, light grey boxes represent an analysis, and dark grey boxes represent final outputs. ‘Point’ data refers to records associated with a location less than 25 km<sup>2</sup>; ‘Polygon’ data refers to records associated with a location greater than 25 km<sup>2</sup>.

## Results
![Alt text](https://preview.ibb.co/nJzb0v/Figure_3.png "Predicted environmental suitability for Culex tritaeniorhynchus within areas at risk of Japanese encephalitis transmission")

Predicted environmental suitability for *Culex tritaeniorhynchus* within areas at risk of Japanese encephalitis transmission. The map shows the predicted relative environmental suitability for *Culex tritaeniorhynchus* at each 5 × 5 km gridded cell within the limits of Japanese encephalitis, on a scale of low environmental suitability (0) to high environmental suitability (1.0).
