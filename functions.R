# Bivariate colour scales -----------------------
# Create a custom 5X5 colour palette
# https://cran.r-project.org/web/packages/biscale/vignettes/bivariate_palettes.html
purple_pal <- c(
  "1-1" = "#e8e8e8",
  "2-1" = "#d3bce5",
  "3-1" = "#be90e1",
  "4-1" = "#a861dd",
  "5-1" = "#8025c5",
  "1-2" = "#c9e8cd",
  "2-2" = "#c9bccd",
  "3-2" = "#be90cd",
  "4-2" = "#a861cd",
  "5-2" = "#8d29cd",
  "1-3" = "#a4e8ad",
  "2-3" = "#a4bcad",
  "3-3" = "#a490ad",
  "4-3" = "#a461ad",
  "5-3" = "#8d29ad",
  "1-4" = "#74e884",
  "2-4" = "#74bc84",
  "3-4" = "#749084",
  "4-4" = "#746184",
  "5-4" = "#742984",
  "1-5" = "#02e821",
  "2-5" = "#02bc21",
  "3-5" = "#029021",
  "4-5" = "#026121",
  "5-5" = "#022921")



leaflet_biplot <- function(d) {
  #https://rstudio.github.io/leaflet/articles/morefeatures.html

  info <- readr::read_rds("data/city_info.rds") |>
    filter(pcname == d$pcname[1])
  
  p <- create_grid_legend(d, purple_pal)
 
  d <- d |>
    filter(good_effort == TRUE) |>
    mutate(bi_colours = unname(bi_colours)) |>
    mutate(across(contains("label_"), \(x) map(x, htmltools::HTML)))

  m <- leaflet(data = d) |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satelite") |>
    addProviderTiles(providers$Esri.WorldTopoMap, group = "Terrain")
  
  dd <- filter(d, bi_class == "5-5")
  if(nrow(dd) > 0) {
    m <- addPolygonsCustom(
      map = m, data = dd,
      group = "Hotspots", popup = ~label_bi, fillColor = ~bi_colours,
      label = ~label_bi)
  }
  dd <- filter(d, bi_class ==  "1-1")
  if(nrow(dd) > 0) {
    m <- addPolygonsCustom(
      map = m, data = dd,
      group = "Coldspots", popup = ~label_bi, fillColor = ~bi_colours, 
      label = ~label_bi)
  }
  
  dd <- filter(d, bi_class %in% c("1-5", "5-1"))
  if(nrow(dd) > 0) {
    m <- addPolygonsCustom(
      map = m, data = dd, 
      group = "Trade-offs", popup = ~label_bi, fillColor = ~bi_colours,
      label = ~label_bi)
  }
  
  dd <- filter(d, !bi_class %in% c("1-1", "1-5", "5-1", "5-5"))
  if(nrow(dd) > 0) {
    m <- addPolygonsCustom(
      map = m, data = dd,
      group = "Other", popup = ~label_bi, fillColor = ~bi_colours,
      label = ~label_bi)
  }
  
  m |> 
    addControl(
      position = "bottomright",
      html = p) |>
    addControl(position = "bottomleft",
               html = paste0(
                 "<div>",
                 "<strong>Population:</strong> ", format(info$population, big.mark = ","), "<br>",
                 "<strong>Area (km²):</strong> ", format(info$area, big.mark = ","),  "<br>",
                 "<span style='font-size:8pt'>Stats Canada 2021 Census for metropolitan areas</span>")) |>
    addLayersControl(
      baseGroups = c("Terrain", "Satelite"),
      overlayGroups = c("Hotspots", "Coldspots", "Trade-offs", "Other"),
      options = layersControlOptions(collapsed = TRUE)) |>
    addScaleBar(position = "topleft")
}

leaflet_uniplot <- function(
    d, var, var_nice, labFormat = labelFormat(),
    pal = "plasma", # pal = colorspace::sequential_hcl(20, "terrain2")
    filter_labels = c("Excluded from bivariate", "Included in bivariate")) {
  # filter_labels = c("Adequate eBird sampling", "Poor eBird sampling")
  
  #https://rstudio.github.io/leaflet/articles/morefeatures.html

  d$var <- d[[var]]
  d[[paste0("label_", var)]] <- paste0("<strong>", d[[paste0("label_", var)]], "</strong>")

  d <- d |>
    relocate(label_bi, label_cnpy_mn, label_hght_mn, label_age_mn, label_nlsp_mn, label_blsp_mn,
             .after = "uniq_id") |>
    rowwise() |>
    mutate(label_overall = paste0(c_across(contains("label_")), collapse = "<br>")) |>
    ungroup() |>
    mutate(across(contains("label_"), \(x) map(x, htmltools::HTML))) |>
    filter(!(is.na(f_ric) & is.na(cnpy_mn) & is.na(hght_mn) & 
               is.na(age_mn) & is.na(nlsp_mn) & is.na(blsp_mn)))
  
  
  pal <- colorNumeric(pal, domain = d[[var]])
  
  # Base map
  m <- leaflet(data = d) |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satelite") |>
    addProviderTiles(providers$Esri.WorldTopoMap, group = "Terrain")
  
  # Add different layers by filtered status
  dd <- filter(d, good_effort == FALSE)
  if(nrow(dd) > 0) {
    m <- addPolygonsCustom(
      map = m, data = dd,
      group = filter_labels[1], 
      popup = ~label_overall,
      fillColor = ~pal(var),
      label = ~label_overall)
  }
  dd <- filter(d, good_effort == TRUE)
  if(nrow(dd) > 0) {
    m <- addPolygonsCustom(
      map = m, data = dd,
      group = filter_labels[2], 
      popup = ~label_overall,
      fillColor = ~pal(var),
      label = ~label_overall)
  }
  
  m |>
    addLegend("bottomright", pal = pal, values = ~var, bins = 5,
              title = paste0("<div class='leg-title'>", var_nice, "</div>"), 
              opacity = 1, group = var_nice,
              labFormat = labFormat) |>
    addLayersControl(
      baseGroups = c("Terrain", "Satelite"),
      overlayGroups = filter_labels,
      options = layersControlOptions(collapsed = TRUE)) |>
    addScaleBar(position = "topleft")
}


addPolygonsCustom <- function(map, ...) {

  addPolygons(map,
              fillOpacity = 0.75,
              stroke = TRUE, color = "black", opacity = 1, weight = 0.75,
              highlightOptions = highlightOptions(fillColor = "orange",
                                                  fillOpacity = 1,
                                                  bringToFront = TRUE),
              ...)
}

                   
create_grid_legend <- function(data, palette, dim = 5, digits = 2) {
  # Prepare colour tiles

  grid <- matrix(palette, byrow = TRUE, nrow = dim)
  grid <- t(grid)
  grid <- grid[, dim:1, drop = FALSE] # Transform to correct orientation
  grid <- t(grid)
  grid <- as.character(grid) |>
    setNames(interaction(1:5, 1:5, sep = "-") |> levels())
  
  grid <- create_tile_div(grid, cells = stringr::str_remove(names(palette), "-"))
  
  # Get legend labels
  b <- bi_class_breaks(data, x = f_ric_bin, y = crb_sm_bin, dim = 5,
                       dig_lab = digits, split = TRUE) |>
    suppressWarnings()
 
  b <- sapply(b, \(x) (lead(x) - x)/2 + x) # Get mid points of breaks
  b <- na.omit(b)
  b <- format(b, digits = digits-1)
  
  x_labs <- create_tile_div(text = b[, "bi_x"], class = "leg-bottom-number")
  y_labs <- create_tile_div(text = rev(b[, "bi_y"]), class = "leg-side-number")
  
  grid <- c(grid, x_labs, y_labs, create_tile_div(class = "leg-empty"))
  
  # Prepare CSS/HTML
  paste(
    "<style>", 
    paste0(readLines("styles.css"), collapse = "\n"), 
    create_styles(dim),
    "</style>",
    "<div class='leg-grid-container'>",
    "<div class='leg-grid-item leg-bottom-label leg-bl'>Functional Richness &rarr;</div>",
    "<div class='leg-grid-item leg-side-label leg-sl'>Carbon &rarr;</div>",
    paste0(grid, collapse = "\n"),
    "</div>",
    sep = "\n")
}

create_tile_div <- function(colour = NULL, text = NULL, class = NULL, cells = NULL) {
  if(!is.null(colour)) colour <- paste0(" style='background-color:", colour, ";'")
  cls <- c("leg-grid-item")
  
  # If working with labels or spacers
  if(!is.null(class)) {
    cls <- paste(cls, class) 
    if(class == "leg-bottom-number") cls <- paste(cls, paste0("leg-b", seq_len(length(text))))
    if(class == "leg-side-number") cls <- paste(cls, paste0("leg-s", seq_len(length(text))))
    if(class == "leg-empty") cls <- paste(cls, "leg-cell", paste0("leg-X", 1:2))
  }
  
  # If working with coloured tiles
  if(!is.null(cells)) {
    cls <- paste(cls, "leg-cell", paste0("leg-c", cells))
    text <- character(length(cells))
    text[cells == "11"] <- "<span class='leaflet-tooltip leg-tooltip'>Research &<br>Management (1-5)</span>"
    text[cells == "51"] <- "<span class='leaflet-tooltip leg-tooltip'><strong>Coldspots (1-1)</strong><br>Restoration</span>"
    text[cells == "55"] <- "<span class='leaflet-tooltip leg-tooltip leg-tooltip-left'>Research &<br>Management (5-1)</span>"
    text[cells == "15"] <- "<span class='leaflet-tooltip leg-tooltip leg-tooltip-left'><strong>Hotspots (5-5)</strong><br>Conservation</span>"
  }
  
  paste0("  <div class='", cls, "'", colour, ">", text, "</div>")
}


create_styles <- function(dim) {
  
  cell <- c() 
  for(i in seq_len(dim)) cell <- c(cell, paste0("c", i, seq_len(dim)))
  
  cells <- character(dim)
  for(i in seq_len(dim)) {
    cells[i] <- paste0("    'sl s", i, paste0(" c", i, seq_len(dim), collapse = ""), "'")
  }
  cells <- paste0(cells, collapse = "\n")
  
  paste(
    ".leg-grid-container {",
    "  display: grid;",
    "  grid-template-areas:",
    cells, 
    paste0("    'sl X1 ", paste0(" b", seq_len(dim), collapse = " "), "'"),
    paste0("    'X2 ", paste0(rep("bl", dim + 1), collapse = "  "), "';"), 
    "  padding: 0;",
    "}",
    paste0(paste0(".leg-", cell, " { grid-area: ", cell, "; }"), collapse = "\n"),
    paste0(paste0(".leg-s", seq_len(dim), " { grid-area: s", seq_len(dim), "; }"), collapse = "\n"),
    paste0(paste0(".leg-b", seq_len(dim), " { grid-area: b", seq_len(dim), "; }"), collapse = "\n"),
    ".leg-X1 { grid-area: X1; }",
    ".leg-X2 { grid-area: X2; }",
    ".leg-bl { grid-area: bl; }",
    ".leg-sl { grid-area: sl; }",
    
    sep = "\n")
}


bin_var <- function(v) {
  cut(v, breaks = classIntervals(v, n = 5, style = "kmeans")$brks,
      include.lowest = TRUE, dig.lab = 1)
}

add_coords <- function(sf, geometry = "geometry") {
  bind_cols(sf, st_coordinates(sf[[geometry]]))
}
