globalVariables(c("geometry"))

#' Load OnMarg spatial data
#'
#' This function combines Public Health Ontario's Ontario Marginalization Index data with Statistics Canada's shape files to create an sf_object.  The sf_object can be used for mapping with packages such as ggplot, and for spatial analysis.
#'
#' If a year or level is used that does not exist or is not implemented, an error message will be produced.
#' If the geometry file is unable to be downloaded, an error message will be produced.
#' @param year Integer year of data to load
#' @param level The level of precision to load, this can be "DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", or "LHIN_SRUID"
#' @param format The format for the geographic object, this can be "sf" or "sp"
#' @return A sf or sp object containing the Marginalization Index and geographic boundaries for every geographic identifier
#' @import dplyr
#' @import httr
#' @import readxl
#' @import sf
#' @import stringr
#' @import utils
#' @export
#' @examples
#' \donttest{
#' DA_2016_geo <- om_geo(2016, "DAUID", "sf")
#' }

om_geo <- function(year, level, format) {
  # Initial setup
  year <- toString(year)
  CRS_to_use <- st_crs("+init=EPSG:2962") # NAD83 UTM Zone 17N
  geoLevels <- c("DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", "LHIN_SRUID")


  # Print warning if requested level does not exist
  if (!level %in% geoLevels) {
    stop(paste0("Level ", level, " is not recognized"))
  }


  # Gets the correct information for a given year
  switch(year,
         # stats_url <- URL for the shapefile
         "2001"={
           #stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000b01a_e.zip"
           stop("This year has not yet been implemented")
         },
         "2006"={
           #stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000a06a_e.zip"
           stop("This year has not yet been implemented")
         },
         "2011"={
           stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000a11a_e.zip"
         },
         "2016"={
           stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lda_000b16a_e.zip"
         },
         {
           # Breaks if an invalid ON-Marg year is entered
           stop("There is no record for year " + year)
         }
  )

  # Gets the page name for the given level and year as "page"
  if (level == "DAUID") {
    prefix <- "DA"
  }
  else {
    prefix <- level
  }

  if (year == "2011" || level == "DAUID") {
    page <- paste0(prefix, "_", year)
  }
  else {
    page <- paste0(year, "_", prefix)
  }


  # Gets the name of a file from its URL
  getFileName <- function(url, extension) {
    str_extract(url, "\\/([a-z]|[0-9]|_)+.zip") %>%
      substring(2) %>%
      str_replace(".zip", ".shp")
  }


  # Extracts all geographic files from zip
  extractFromZip <- function(url) {
    tempDir <- tempdir()
    tempFile <- tempfile()

    filename <- getFileName(url)

    tryCatch(
      download.file(url, tempFile, quiet=TRUE, mode="wb"),
      # Creates an error if the file is unable to download
      error = function(e) stop("Geography file was unable to be downloaded")
    )

    extensions <- c(".shp", ".dbf", ".prj", ".shx")
    for (extension in extensions) {
      filename <- str_extract(url, "\\/([a-z]|[0-9]|_)+.zip") %>%
        substring(2) %>%
        str_replace(".zip", extension)

      unzip(tempFile, filename, exdir=tempDir)
    }

    filepath <- paste0(tempDir, "/", filename)

    return(st_read(filepath))
  }


  # Loads a dataframe containing marginalization data
  df1 <- om_data(year, level)


  # Loads a dataframe containing shape data
  df2 <- extractFromZip(stat_url) %>%
    st_transform(CRS_to_use) #%>%


  # Summarizes the dataframe if not selecting DAUID
  if (!level == "DAUID") {
    df2 <- df2 %>%
      group_by_at(level) %>%
      summarize(geometry=st_union(geometry))
  }


  # Merges geographic location with ON-Marg values and returns the data frame
  shape_marg <- merge(df2, df1, by=level)


  # Makes a marginalization index column
  shape_marg <- mutate(shape_marg, index={
    shape_marg[,grepl("_Q_", names(shape_marg))] %>%
      st_drop_geometry() %>%
      rowMeans()
  })

  # Returns the correct format
  switch(format,
         "sf"={
           return(shape_marg)
         },
         "sp"={
           return(as_Spatial(shape_marg))
         },
         {
           stop("Unrecognized file format used, please specify 'sf' or 'sp'")
         }
  )
}
