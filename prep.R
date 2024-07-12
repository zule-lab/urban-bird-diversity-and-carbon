library(dplyr)
library(tidyr)
library(sf)
library(biscale)
library(classInt)
library(purrr)

# Data descriptions in Data/README.md

bin_var <- function(v) {
  cut(v, breaks = classIntervals(v, n = 5, style = "kmeans")$brks,
      include.lowest = TRUE, dig.lab = 1)
}

add_coords <- function(sf, geometry = "geometry") {
  bind_cols(sf, st_coordinates(sf[[geometry]]))
}

# Load and clean data as required
cities <- st_read("data/bird_diversity_carbon_synergies_and_tradeoffs.shp") |>
  drop_na() |>
  rename(completeness = cmpltns) |>
  filter(completeness > 50, slope < 0.3) |>  # All must have
  filter(pcname == "Regina" | ratio < 3)# |>  # All except Regina must have
  #nest(.by = "pcname") # Create nested data frame so we can iterate over cities next

cities <- split(cities, cities$pcname)

cities["Winnipeg"]

# Prepare mapping data (by city)
cities <- map(cities, \(city) {
  city |>
    # Bin the Data
    mutate(f_ric_bin = bin_var(f_ric),
           crb_sm_bin = bin_var(crb_sm)) |>
    # Add the bi_class to the data
    bi_class(x = f_ric_bin, y = crb_sm_bin, dim = 5) |>
    suppressWarnings() |>
    # Add colours corresponding to the palette
    mutate(colours = purple_pal[bi_class]) |>
    # Create tooltips
    mutate(label_bi = paste0("Cat: ", bi_class, "<br>",
                             "Carbon: ", round(crb_sm, 3), "<br>",
                             "F: ", round(f_ric, 3)),
           label_bi = map(label_bi, htmltools::HTML),
           label_canopy = paste0("Canopy Cover: ", round(cnpy_mn, 2))) |>
    mutate(centroid = st_centroid(geometry)) |>
    add_coords(geometry = "centroid")
})

cities[[1]]
select(cities[[1]], f_ric, crb_sm, f_ric_bin, crb_sm_bin, bi_class, colours)


readr::write_rds(cities, "data/cities.rds")

# Prepare legends (by city)
# legends <- map(cities, \(city) {
# 
#   # Specify the digits for the legend labels
#   digits <- if_else(city$pcname[1] %in% c("Montréal", "Toronto", "Vancouver"), 3, 2)
# browser()
#   # Get legend breaks
#   b <- bi_class_breaks(city, x = f_ric_bin, y = crb_sm_bin, dim = 5,
#                        dig_lab = 10, split = TRUE) |>
#     suppressWarnings()
# 
#   # Create legend
#   bi_legend(pal = purple_pal,
#             dim = 5,
#             xlab = "Functional Richness",
#             ylab = "Carbon",
#             size = 7,
#             breaks = b,
#             arrows = FALSE)
# })
# 
# legends[["Winnipeg"]]
# 
# readr::write_rds(legends, "data/legends.rds")
# 
# g <- ggplot(dd) +
#   theme(legend.position = "none") +
#   annotation_map_tile(zoomin = 0) +
#   geom_sf_interactive(aes(fill = cnpy_mn, tooltip = label, data_id = uniq_id)) #+
#   #scale_fill_manual(values = biscale:::pals$PurpleGrn$d4)
# 
