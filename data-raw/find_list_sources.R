u <- "https://listdata.thelist.tas.gov.au/opendata/data"
tx <- readLines(u)
# length(tx)
# grep("zip", tx)

zips <- file.path(u, gsub("\"$", "", gsub("href=\"", "", stringr::str_extract(grep("zip", tx, value = TRUE), "href=\".*zip\""))))
vsizips <- file.path("/vsizip//vsicurl", zips)

writeLines(vsizips, "data-raw/list.sources.txt")


#if (FALSE) {
  f <- purrr::safely(vapour::vapour_vsi_list)
  l <- purrr::map(vsizips, f)
  bad <- unlist(lapply(l, \(.x) is.null(.x$result)))
  ##none
  sum(bad)

  d <- tibble::tibble(url = zips, dsn = vsizips, vsilist = lapply(l, \(.x) .x$result))
  dd <- tidyr::unnest(d, "vsilist")
  writeLines(sort(unique(tools::file_ext(dd$vsilist))), "data-raw/listmap-sources-unique_file_ext.txt")
  d2 <- dd[tools::file_ext(dd$vsilist) %in% c("asc", "tif", "zip", "gdbtable", "csv", "zip"), ]

  ## make sure we don't include every sub gdb/ file (we might want to detect which are raster/vector)
  gdb <- tools::file_ext(dirname(d2$vsilist)) == "gdb"
  d2$vsilist[gdb] <- dirname(d2$vsilist[gdb])
  library(dplyr)
  d2 <- d2 |> distinct()

arrow::write_parquet(d2, "data-raw/listmap-sources-vsi.parquet")
readr::write_csv(d2, "data-raw/listmap-sources-vsi.csv")
#}


