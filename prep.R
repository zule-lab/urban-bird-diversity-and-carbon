library(dplyr)    # Data manipulation
library(tidyr)    # Data manipulation
library(sf)       # Spatial data
library(leaflet)  # Maps
library(leaflet.minicharts) # Synchronization among plots
library(purrr)    # Loops and lists
library(biscale)  # Bi-scales
library(classInt) # Binning

source("functions.R")

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
    mutate(
      highlight = case_match(
        bi_class,
        "1-1" ~ "<strong>Cold spot:</strong> Target restoration<br>",
        "5-5" ~ "<strong>Hotspot:</strong> Target conservation<br>",
        "1-5" ~ "<strong>High Carbon:</strong> Target research & management<br>",
        "5-1" ~ "<strong>High Richness:</strong> Target research & management<br>",
        .default = ""),
      label_bi = paste0(
        highlight,
        "Bivarate Category: ", bi_class, "<br>",
        "Carbon: ", round(crb_sm, 3), "<br>",
        "Richness: ", round(f_ric, 3)),
      label_cnpy_mn = paste0("Canopy Cover: ", round(cnpy_mn, 2)),
      label_hght_mn = paste0("Stand Height: ", round(hght_mn, 2)),
      label_age_mn = paste0("Stand Age: ", round(age_mn, 2)),
      label_nlsp_mn = paste0("% Needle-leaved Trees: ", round(nlsp_mn, 2)),
      label_blsp_mn = paste0("% Broad-leaved Trees: ", round(blsp_mn, 2))) |>
    mutate(centroid = st_centroid(geometry)) |>
    add_coords(geometry = "centroid")
})

cities[[1]]
select(cities[[1]], f_ric, crb_sm, f_ric_bin, crb_sm_bin, bi_class, colours)


readr::write_rds(cities, "data/cities.rds")

# Get city info
# Stats Canada, based on 2021 census and Metropolitan areas
# - https://www12.statcan.gc.ca/census-recensement/2021/dp-pd/prof/details/download-telecharger.cfm?Lang=E
city_info <- readr::read_csv("data/98-401-X2021002_eng_CSV/98-401-X2021002_English_CSV_data.csv", guess_max = Inf) |>
  janitor::clean_names() |>
  mutate(geo_name = if_else(geo_name == "Montr\xe9al", "Montréal", geo_name)) |>
  filter(geo_name %in% names(cities),
         census_year == 2021,
         characteristic_name %in% c("Population, 2021", "Land area in square kilometres")) |>
  select(census_year, pcname = geo_name, value = c1_count_total, type = characteristic_name) |>
  mutate(type = if_else(stringr::str_detect(type, "Population"), "population", "area")) |>
  pivot_wider(names_from = "type", values_from = "value")

readr::write_rds(city_info, "data/city_info.rds")
