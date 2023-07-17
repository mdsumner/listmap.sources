u <- "https://listdata.thelist.tas.gov.au/opendata/data"
tx <- readLines(u)
# length(tx)
# grep("zip", tx)

zips <- file.path(u, gsub("\"$", "", gsub("href=\"", "", stringr::str_extract(grep("zip", tx, value = TRUE), "href=\".*zip\""))))
vsizips <- file.path("/vsizip//vsicurl", zips)

writeLines(vsizips, "data-raw/list.sources.txt")


if (FALSE) {
  f <- purrr::safely(vapour::vapour_vsi_list)
  l <- purrr::map(vsizips, f)
  bad <- unlist(lapply(l, \(.x) is.null(.x$result)))
  ##none
  sum(bad)

  d <- tibble::tibble(url = zips, dsn = vsizips, vsilist = lapply(l, \(.x) .x$result))
  dd <- tidyr::unnest(d, "vsilist")
  d2 <- dd[tools::file_ext(dd$vsilist) %in% c("asc", "tif", "zip", "gdbtable"), ]
  dim(d2)

  gdb <- tools::file_ext(dirname(d2$vsilist)) == "gdb"
  d2$vsilist[gdb] <- dirname(d2$vsilist[gdb])
  library(dplyr)
  d2 <- d2 |> distinct()
  d2$type <- tools::file_ext(d2$vsilist)
  dsn <- d2 |> filter(type == "asc") |> mutate(dsn  = file.path(dsn, vsilist)) |> pull(dsn)




}


