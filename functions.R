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
  d$colours <- unname(d$colours)
  
  d <- mutate(d, across(contains("label_"), \(x) map(x, htmltools::HTML)))

  leaflet(data = d) |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satelite") |>
    addProviderTiles(providers$CartoDB.Positron, group = "Black and White") |>
    addProviderTiles(providers$Stadia.StamenTerrain, group = "Terrain") |>
    
    addPolygons(
      data = filter(d, bi_class %in% c("1-1", "1-5", "5-1", "5-5")),
      group = "Priority spots", popup = ~label_bi,
      fillColor = ~colours, opacity = 0, fillOpacity = 0.75,
      stroke = FALSE,
      highlightOptions = highlightOptions(fillColor = "orange",
                                          fillOpacity = 1,
                                          bringToFront = TRUE),
      label = ~label_bi) |>
    
    addPolygons(
      data = filter(d, !bi_class %in% c("1-1", "1-5", "5-1", "5-5")),
      group = "Intermediate spots", popup = ~label_bi,
      fillColor = ~colours, opacity = 0, fillOpacity = 0.75,
      stroke = FALSE,
      highlightOptions = highlightOptions(fillColor = "orange",
                                          fillOpacity = 1,
                                          bringToFront = TRUE),
      label = ~label_bi) |>
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
      baseGroups = c("Terrain", "Satelite", "Black and White"),
      overlayGroups = c("Intermediate spots", "Priority spots"),
      options = layersControlOptions(collapsed = FALSE))
}

leaflet_uniplot <- function(d, var, var_nice, labFormat = labelFormat(),
                            pal = "plasma") {
  #https://rstudio.github.io/leaflet/articles/morefeatures.html

  #pal <- colorNumeric(colorspace::sequential_hcl(20, "terrain2"), domain = d[[var]])
  pal <- colorNumeric(pal, domain = d[[var]])
  
  d$var <- d[[var]]
  d[[paste0("label_", var)]] <- paste0("<strong>", d[[paste0("label_", var)]], "</strong>")

  d <- d |>
    rowwise() |>
    mutate(label_overall = paste0(c_across(contains("label_")), collapse = "<br>")) |>
    ungroup() |>
    mutate(across(contains("label_"), \(x) map(x, htmltools::HTML)))
  

  leaflet(data = d) |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satelite") |>
    addProviderTiles(providers$CartoDB.Positron, group = "Black and White") |>
    addProviderTiles(providers$Stadia.StamenTerrain, group = "Terrain") |>
    
    addPolygons(
      group = var_nice, popup = ~label_overall,
      fillColor = ~pal(var), opacity = 0, fillOpacity = 0.75,
      color = "white", stroke = FALSE,
      highlightOptions = highlightOptions(fillColor = "orange",
                                          fillOpacity = 1,
                                          bringToFront = TRUE),
      label = ~label_overall) |>
    addLegend("bottomright", pal = pal, values = ~var, bins = 5,
              title = paste0("<div class='leg-title'>", var_nice, "</div>"), 
              opacity = 1, group = var_nice,
              labFormat = labFormat) |>
    addLayersControl(
      baseGroups = c("Terrain", "Satelite", "Black and White"),
      options = layersControlOptions(collapsed = FALSE))
}
                   
create_grid_legend <- function(data, palette, dim = 5, digits = 2) {
  # Prepare colour tiles
  cells <- create_tile_div(palette)
  grid <- matrix(cells, byrow = TRUE, nrow = dim)
  grid <- grid[dim:1, , drop = FALSE] # Transform to correct orientation
  grid <- t(grid)
  #grid <- grid[, dim:1 , drop = FALSE] # Transform to correct orientation
  # Get legend labels
  b <- bi_class_breaks(data, x = f_ric_bin, y = crb_sm_bin, dim = 5,
                       dig_lab = digits, split = TRUE) |>
    suppressWarnings()
  
  b <- sapply(b, \(x) (lead(x) - x)/2 + x) # Get mid points of breaks
  b <- na.omit(b)
  b <- format(b, digits = digits-1)
  
  x_labs <- create_tile_div(text = b[, "bi_x"], class = "top")
  y_labs <- create_tile_div(text = rev(b[, "bi_y"]), class = "side")
  
  grid <- cbind(x_labs, grid)
  grid <- rbind(c(create_tile_div(class = "top side"), y_labs), grid)
  
  # Prepare CSS/HTML
  style <- paste(
    "<style>",
    ".grid-container {",
    "  display: grid;",
    "  grid-template-columns: ", paste0(rep("auto", dim + 1), collapse = " "), ";",
    "  padding: 0;",
    "}",
    ".grid-item {",
    "  display: flex;",
    "  justify-content: center;",
    "  align-items: center;",
    "  font-size: 8pt;",
    "  text-align: right;",
    "  padding: 4px;",
    "  width: 15pt;",
    "  height: 15pt;",
    "}",
    ".side {",
    "  width: 15pt;",
    #"  align-items: center;",
    # "  margin-right: 2px;",
    #"  margin-top: auto;",
    #"  padding-right: 0;",
    "}",
    ".top {",
    "  height: 15pt;",
    #"  text-align: center;",
    #"  margin-top: 50%;",
    #"  margin-bottom: 2px;",
    #"  padding-bottom: 0;",
    "}",
    "</style>",
    "<div class='grid-container'>",
    paste0(grid, collapse = "\n"),
    "</div>",
    sep = "\n")
}

create_tile_div <- function(colour = NULL, text = NULL, class = NULL) {
  if(!is.null(colour)) colour <- paste0(" style='background-color:", colour, ";'")
  cls <- "grid-item"
  if(!is.null(class)) cls <- paste(cls, class)
  paste0("  <div class='", cls, "'", colour, ">", text, "</div>")
}