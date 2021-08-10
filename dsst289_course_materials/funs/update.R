#' Checks available materials from GitHub and downloads those that do not
#' currently exist locally.
.update_materials <- function()
{
  base <- "https://raw.githubusercontent.com/statsmaths/dsst289-f21/main/uploads/"

  # what files are available to download?
  avail <- readLines(file.path(base, "manifest.txt"))
  avail <- avail[avail != ""]

  # download files that do not exist
  downloaded <- c()
  for (f in avail)
  {
    if (!file.exists(f))
    {
      url <- file.path(base, f)
      download.file(url, f, quiet = TRUE)
      downloaded <- c(downloaded, f)
    }
  }

  dt <- as.character(as.POSIXlt(Sys.time(), format = "%Y-%m-%dT%H:%M:%S"))
  if (length(downloaded))
  {
    message(sprintf("[%s] Downloaded file %s\n", dt, downloaded))
  } else {
    message(sprintf("[%s] Nothing new to download.", dt))
  }
}

.update_materials()
