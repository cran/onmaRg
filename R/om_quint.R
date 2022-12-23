#' This function converts an arbitrary vector of values into corresponding quintile scores.
#'
#' NA values are ignored and left NA
#'
#' It can be used to recalculate the quintile scores for subsets of the OnMarg dataset.
#'
#' @param x Vector of values to recalculate quintiles for
#' @return Vector of quintile scores for each element in the input vector
#' @importFrom stats quantile
#' @export
#' @examples
#' \dontrun{
#' city_data$DEPRIVATION_Q_DA16 <- om_quint(city_data$DEPRIVATION_DA16)
#' }

om_quint <- function(x) {
  # Make bins to put values into
  quint <- quantile(x, probs=seq(0,1,0.2), na.rm=TRUE)

  new_x <- c()
  for (i in 1:length(x)) {
    # Return NA if value is NA
    if (is.na(x[i])) {
      new_x[i] <- NA
    }
    # Put value in appropriate bin
    else {
      for (j in 2:6) {
        if (x[i] <= quint[j]) {
          new_x[i] <- j - 1
          break
        }
      }
    }
  }
  return(new_x)
}
