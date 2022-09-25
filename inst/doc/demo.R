## ---- eval=FALSE--------------------------------------------------------------
#  library(onmaRg)
#  library(ggplot2)
#  
#  DA_2016 <- om_geo(2016, "DAUID", "sf") %>%
#    filter(CSDNAME == "Toronto")
#  
#  plot <- ggplot() +
#    geom_sf(data=DA_2016, aes(fill=DEPRIVATION_Q_DA16))

