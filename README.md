# onmaRg Library

## Purpose

onmaRg is an R library that takes care of loading and merging Ontario Marginalization data. This includes functions for automatically creating dataframes containing marginalization data joined with geographic data, allowing the spatial analysis of this data to be more accessible.

onmaRg takes all of it's data directly off of the government websites and merges them into a dataframe without creating any permanant local files.

## Background

The Ontario Marginalization Index is a data model that has been developed and maintained by Ontario Public Health and St. Michael's Hospital. This data model is constructed with the four domains of Residential Instability, Material Deprivation, Dependency and Ethnic Concentration which describe different aspects of marginalization that is experienced by communities. This data is available as a decimal, as well as in quintiles from 1 to 5 (5 being the highest level of that measurement, e.g.: deprivation 5 is the highest level of deprivation).

Statistics Canada has a database shapefiles on the geographic boundaries of all of Canada. This includes many levels that can go as precisely as Dissemination Areas.

onmaRg draws from both of these sources to create a shapefile that also contains marginalization data for each mapped space. This makes it much easier to work with this data and represent it visually, automating the process of downloading the different files, cleaning them and joining them together in a format that can be analyzed.

In addition, onmaRg also calculates an index score based on the five quintiles as an overall average score between each dimension.

## Available Data

The Ontario Marginalization Index has released marginalization information on several levels every five years starting in 2001.

onmaRg can retrieve data from the following years:
- 2011
- 2016
- 2021 - Pending

onmaRg can retrieve data from the following levels:
- DAUID
- CTUID
- CSDUID
- CCSUID
- CDUID
- CMAUID
- PHUUID
- LHINUID
- LHIN_SRUID

onmaRg will be updated every time a new dataset comes out to keep it relevant. The years 2001 and 2006 have been excluded due to differences in formatting, but will be made available in future versions.

## Usage

The `shapeMarg()` function is used to download the data into a variable - simply put in the year of data requested and the level of precision. This example will showcase how to use the package to quickly make a geographic plot of material deprivation data:

```r
library(onmaRg)
library(ggplot2)
library(sf)

# Loads OnMarg data from 2016 on the DA level
DA_2016 <- shapeMarg(2016, "DAUID")

# Plots the material deprivation quintile scores
ggplot() +
    geom_sf(data=DA_2016, aes(fill=DEPRIVATION_Q_DA16)) +
    coord_sf()
```
![](Example1.jpg)