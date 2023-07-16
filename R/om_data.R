#' Load OnMarg data
#'
#' This function loads Public Health Ontario's Ontario Marginalization Index data into a dataframe which includes geographic variables (e.g. DA labels, CSD labels) and associated values for the four OnMarg domains of Instability, Material Deprivation, Dependency and Ethnic Concentration.
#'
#' If the data file is unable to be downloaded, an error message will be produced.
#' @param year Integer year of data to load
#' @param level The level of precision to load, this can be "DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", or "LHIN_SRUID"
#' @return A dataframe containing the Marginalization Index for every geographic identifier
#' @import dplyr
#' @import httr
#' @import readxl
#' @import sf
#' @import stringr
#' @import utils
#' @export
#' @examples
#' DA_2016_data <- om_data(2016, "DAUID")
om_data <- function(year, level) {
  # Initial setup
  year <- toString(year)
  geoLevels <- c("DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", "LHIN_SRUID")

  # Print warning if requested level does not exist
  if (!level %in% geoLevels) {
    stop(paste0("Level ", level, " is not recognized"))
  }

  # ============================================================================
  # Processing functions
  # ============================================================================

  process_2011_2016 <- function(year, url, format) {
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

    # Loads the worksheet into a temporary file (tf)
    tryCatch(
      GET(url, write_disk(tf <- tempfile(fileext=format))),
      # Creates an error if the file is unable to download
      error = function(e) stop("Data file was unable to be downloaded")
    )

    # Loads a dataframe containing marginalization data
    phodata <- read_excel(tf, sheet=page)
    colnames(phodata) <- toupper(colnames(phodata))

    return(phodata)
  }



  process_2021 <- function(url) {
    # Gets the page name for the given level and year as "page"
    if (level == "DAUID") {
      page <- paste0("DA_", year)
    }
    else {
      page <- paste0(year, "_", level)
    }

    # Loads the worksheet into a temporary file (tf)
    tryCatch(
      GET(url, write_disk(tf <- tempfile(fileext=".xlsx"))),
      # Creates an error if the file is unable to download
      error = function(e) stop("Data file was unable to be downloaded")
    )

    # Loads a dataframe containing marginalization data
    phodata <- read_excel(tf, sheet=page)
    colnames(phodata) <- toupper(colnames(phodata))

    return(phodata)
  }

  #=============================================================================
  # Main Switch
  #=============================================================================

  # Gets the correct information for a given year
  switch(year,
         # url       <- URL for the marginalization data
         # format    <- Format of the file
         "2001"={
           #url <- "http://www.ontariohealthprofiles.ca/onmarg/userguide_data/ON-Marg_2001_updated_May_2012.xls"
           #format <- ".xls"
           stop("This year has not yet been implemented")
         },
         "2006"={
           #url <- "http://www.ontariohealthprofiles.ca/onmarg/userguide_data/ON-Marg_2006_updated_May_2012.xls"
           #format <- ".xls"
           stop("This year has not yet been implemented")
         },
         "2011"={
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg-2011.xlsx?la=en&sc_lang=en&hash=88EFEB83D1A1DFC5A90517AE2E71C855"
           phodata <- process_2011_2016("2011", url, ".xlsx")
         },
         "2016"={
           #url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg.xls?sc_lang=en"
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg-2016.xls?sc_lang=en&rev=be5ab11ce0cc4fe5ab99ee66d359fd00&hash=8AE291D54B3AD013A106D27139218CE8"
           phodata <- process_2011_2016("2016", url, ".xls")
         },
         "2021"={
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg.xlsx?rev=c778f01c70294d779131bbdb50c23049&sc_lang=en"
           phodata <- process_2021(url)
         },
         {
           # Breaks if an invalid ON-Marg year is entered
           stop("There is no record for year " + year)
         }
  )

  return(phodata)
}
