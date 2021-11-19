source("start.R")
source("cache.R")

library(nycflights13)

flights <- nycflights13::flights
flights <- flights %>%
  filter(!(dest %in% c("HNL", "ANC"))) %>%
  mutate(dep_min = as.numeric(stri_sub(dep_time, -2, -1))) %>%
  mutate(dep_hour = as.numeric(stri_sub(dep_time, 1, -3))) %>%
  mutate(arr_min = as.numeric(stri_sub(arr_time, -2, -1))) %>%
  mutate(arr_hour = as.numeric(stri_sub(arr_time, 1, -3))) %>%
  mutate(dep_delay = dep_delay * 60) %>%
  mutate(arr_delay = arr_delay * 60) %>%
  select(origin, dest, year, month, day, dep_hour, dep_min, dep_delay, arr_hour,
         arr_min, arr_delay, carrier, tailnum) %>%
  na.omit()

weather <- weather %>%
  select(origin, time_hour, temp, wind_speed, visib) %>%
  na.omit()

airports <- airports %>%
  select(faa, name, lon, lat, tzone) %>%
  na.omit()

write_csv(flights, "data/flights.csv")
write_csv(weather, "data/weather.csv")
write_csv(airports, "data/airports.csv")
