library(tidyverse)
library(jsonlite)
library(sf)
library(tigris)
library(stringi)

#############################
# Roads
geo <- roads("NY", "New York")
geo <- select(geo, name = FULLNAME)
file.remove("data/ny_roads.geojson")
write_sf(geo, "data/ny_roads.geojson")
geo <- read_sf("data/ny_roads.geojson")

geo <- roads("VA", "Richmond city")
geo <- select(geo, name = FULLNAME)
file.remove("data/rva_roads.geojson")
write_sf(geo, "data/rva_roads.geojson")
geo <- read_sf("data/rva_roads.geojson")

geo <- primary_roads()
file.remove("data/usa_roads.geojson")
geo <- filter(geo, RTTYP == "I")
geo <- select(geo, name = FULLNAME)
write_sf(geo, "data/usa_roads.geojson")
geo <- read_sf("data/usa_roads.geojson")

geo <- filter(geo, name %in% c("I- 95", "I- 195", "I- 295", "I- 395" , "I- 495"))
write_sf(geo, "data/usa_roads_95.geojson")
geo <- read_sf("data/usa_roads_95.geojson")


geo <- states(resolution = "20m")
geo <- select(geo, state = NAME, code = STUSPS, fips = STATEFP)
file.remove("data/states.geojson")
write_sf(geo, "data/states.geojson")
geo <- read_sf("data/states.geojson")

#############################
# GEOJSON World
download.file("https://github.com/datasets/geo-countries/raw/master/data/countries.geojson",
              "data/countries_inter.geojson")
geo <- read_sf("data/countries_inter.geojson")
names(geo) <- c("country", "iso", "iso2", "geometry")
file.remove("data/countries.geojson")
write_sf(geo, "data/countries.geojson")
geo <- read_sf("data/countries.geojson")

#############################
# Hans
hans <- gapminder::gapminder %>%
  rename(life_exp = lifeExp, gdp = gdpPercap) %>%
  mutate(pop = pop / 1000000) %>%
  mutate(country = as.character(country)) %>%
  mutate(continent = as.character(continent))

# which countries are different?
setdiff(hans$country, geo$country)
geo$country[stri_detect(geo$country, fixed = "Yemen")]

hans <- filter(hans, !(country %in% c("Reunion", "West Bank and Gaza")))
hans$country[hans$country == "Congo, Dem. Rep."] <- "Democratic Republic of the Congo"
hans$country[hans$country == "Congo, Rep."] <- "Republic of Congo"
hans$country[hans$country == "Cote d'Ivoire"] <- "Ivory Coast"
hans$country[hans$country == "Guinea-Bissau"] <- "Guinea Bissau"
hans$country[hans$country == "Hong Kong, China"] <- "Hong Kong S.A.R."
hans$country[hans$country == "Korea, Dem. Rep."] <- "North Korea"
hans$country[hans$country == "Korea, Rep."] <- "South Korea"
hans$country[hans$country == "Reunion"] <- ""
hans$country[hans$country == "Serbia"] <- "Republic of Serbia"
hans$country[hans$country == "Slovak Republic"] <- "Slovakia"
hans$country[hans$country == "Tanzania"] <- "United Republic of Tanzania"
hans$country[hans$country == "United States"] <- "United States of America"
hans$country[hans$country == "West Bank and Gaza"] <- ""
hans$country[hans$country == "Yemen, Rep."] <- "Yemen"

write_csv(hans, "data/gapminder_norm.csv")

#############################
# CITIES
z <- read_json("https://github.com/lutangar/cities.json/raw/master/cities.json")

dt <- tibble(
  country = map_chr(z, ~ .x$country),
  name = map_chr(z, ~ .x$name),
  lat = as.numeric(map_chr(z, ~ .x$lat)),
  lon = as.numeric(map_chr(z, ~ .x$lng))
)

write_csv(select(dt, -country), "data/world_cities.csv")

#############################
# FRANCE
geo <- read_sf("data/france_departement.geojson")
z <- read_csv("https://raw.githubusercontent.com/opencovid19-fr/data/master/dist/chiffres-cles.csv", guess_max = 10000)
z <- filter(z, granularite == "departement")
z <- mutate(z, departement = stri_replace_all(maille_code, "", fixed = "DEP-"))
z <- mutate(z, name = maille_nom)   
z2 <- select(z, date, departement, name, cases = cas_confirmes, deaths = deces, hospitalized = hospitalises)

write_csv(z, "data/fr_dep_covid.csv")

#############################
# US
geo <- read_sf("data/us_counties.geojson")
z <- read_csv("https://github.com/nytimes/covid-19-data/raw/master/us-counties.csv")
write_csv(z, "data/us_county_covid.csv")

#############################
# GEOJSON Italy
download.file("https://github.com/openpolis/geojson-italy/raw/master/geojson/limits_IT_provinces.geojson",
              "data/it_province_inter.geojson")
geo_pro <- read_sf("data/it_province_inter.geojson")
geo_pro <- select(geo_pro, province = prov_name)
file.remove("data/it_province.geojson")
write_sf(geo_pro, "data/it_province.geojson")
geo_pro <- read_sf("data/it_province.geojson")

download.file("https://github.com/openpolis/geojson-italy/raw/master/geojson/limits_IT_regions.geojson",
              "data/it_region_inter.geojson")
geo_reg <- read_sf("data/it_region_inter.geojson")
geo_reg <- select(geo_reg, region = reg_name)
file.remove("data/it_region.geojson")
write_sf(geo_reg, "data/it_region.geojson")
geo_reg <- read_sf("data/it_region.geojson")

#############################
# ITALY | COVID
z <- read_csv("https://github.com/DavideMagno/ItalianCovidData/raw/master/Daily_Covis19_Italian_Data_Province_Incremental.csv")
z <- select(z, date = Date, region = Region, province = Province, cases =  `Total Positive`)

# which province are different?
setdiff(z$province, geo_pro$province)
geo_pro$province[stri_detect(geo_pro$province, fixed = "Fuori")]

z <- filter(z, province != "In fase di definizione/aggiornamento")
z <- filter(z, province != "Fuori Regione / Provincia Autonoma")
z$province[z$province == "Bolzano"] <- "Bolzano/Bozen"
z$province[z$province == "Massa Carrara"] <- "Massa-Carrara"
z$province[z$province == "Aosta"] <- "Valle d'Aosta/Vallée d'Aoste"

setdiff(z$province, geo_pro$province)
write_csv(z, "data/it_province_covid.csv")

#############################
# ITALY | VACCINE
v <- read_csv("https://raw.githubusercontent.com/DavideMagno/ItalianCovidData/master/CumulativeDosesData.csv")

# which regions are different?
setdiff(v$nome_area, geo_reg$region)
geo_reg$region[stri_detect(geo_reg$region, fixed = "Trento")]

v <- filter(v, nome_area != "Provincia Autonoma Bolzano / Bozen")
v <- filter(v, nome_area != "Provincia Autonoma Trento")
v$nome_area[v$nome_area == "Valle d'Aosta / Vallée d'Aoste"] <- "Valle d'Aosta/Vallée d'Aoste"

v <- filter(v, tipo_dato %in% c("prime_dosi", "seconde_dosi"))
v$tipo_dato[v$tipo_dato == "prime_dosi"] <- "first dose"
v$tipo_dato[v$tipo_dato == "seconde_dosi"] <- "second dose"
v <- select(v, date = date, region = nome_area, vaccine = fornitore, type = tipo_dato, number = numero_dosi)
write_csv(v, "data/it_region_vaccine.csv")

#############################
# Italy Cities
spatial_join <- function(...) {
  return(st_as_sf(as_tibble(st_join(...))))
}

geo <- read_sf("data/countries.geojson")
world <- read_csv("data/world_cities.csv")
it <- read_csv("data/italy_cities_raw.csv")
names(it) <- c("pop", "city_name")

world_geo <- world %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE)  

it_join <- geo %>%
  filter(iso == "ITA") %>%
  spatial_join(world_geo, left = FALSE) %>%
  as_tibble() %>%
  select(city_name = name, lon, lat) %>%
  inner_join(it, by = "city_name") %>%
  arrange(desc(pop))

write_csv(it_join, "data/italy_cities.csv")
