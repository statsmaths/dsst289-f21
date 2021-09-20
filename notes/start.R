library(tidyverse)
library(ggrepel)
library(smodels)
library(stringi)
library(broom)
library(jsonlite)
library(lubridate)
library(sf)
library(units)
library(RcppRoll)
library(hms)

theme_set(theme_minimal())
options(pillar.min_character_chars = 15)
options(dplyr.summarise.inform = FALSE)
options(readr.show_col_types = FALSE)
options(ggrepel.max.overlaps = Inf)
options(width = 85L)
options(lubridate.week.start = 1)
Sys.setlocale(locale = "en_US.UTF-8")
Sys.setenv(LANG = "en")

sm_centroid <- function(data) {
  suppressWarnings({ z <- st_coordinates(st_centroid(data)) })
  return(tibble(lon = z[,1], lat = z[,2]))
}
spatial_join <- function(...) {
  return(st_as_sf(as_tibble(st_join(...))))
}

