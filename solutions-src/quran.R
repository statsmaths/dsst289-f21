source("start.R")
source("cache.R")

url_str <- modify_url("http://api.alquran.cloud/v1/quran/en.asad")
res <- http_cache_get(url_str, cache_dir = "cache")
stop_for_status(res)
obj <- content(res, type = "application/json")
set <- obj$data$surahs

output <- vector("list", length = length(set))
for (i in seq_along(set))
{

  sname <- sprintf("%03d. %s", set[[i]]$number, set[[i]]$englishNameTranslation)
  output[[i]] <- tibble(
    surah = sname,
    ayah = map_int(set[[i]]$ayahs, ~ .x$number),
    text = map_chr(set[[i]]$ayahs, ~ .x$text)
  )
}

quran <- bind_rows(output)
write_csv(quran, "data/quran.csv")
