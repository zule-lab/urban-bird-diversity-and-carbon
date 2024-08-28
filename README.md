![](https://img.shields.io/badge/status-In_review-yellow)

### Interactive Results for
## Multi-city analysis of synergies and trade-offs between urban bird diversity and carbon storage to inform decision-making



**Authors**: [Riikka P. Kinnunen](mailto:rpkinnunen@gmail.com), [Carly D. Ziter](https://www.carlyziter.com/), [Barbara Frei](https://www.thebirdsthetrees.com/)

**Abstract**: 

Cities are particularly vulnerable to the impacts of biodiversity loss and climate change. Urban greenspaces are important ecosystems that can conserve biodiversity and help offset the carbon footprint of urban areas. However, despite large-scale tree planting and restoration initiatives in cities, it is not well known where trees or vegetation should be planted or restored to achieve multiple benefits. We considered urban greenspaces as nature-based solutions for urban climate mitigation and biodiversity conservation planning. Using bivariate mapping, we examined the spatial synergies and trade-offs between bird functional diversity and carbon storage in ten Canadian cities spanning a gradient of geography and population, and modelled the relationships between vegetation attributes and both bird diversity and amount of carbon. We found carbon and biodiversity are weakly positively correlated across the ten cities, however, this relationship varied in strength, direction and significance. Our maps highlight areas within our target cities where greenspaces could be managed, restored, or protected to maximize carbon storage and conserve biodiversity. Nationwide, our results also show that forest management strategies that promote increases in canopy cover and the proportion of needle-leaved species in urban greenspaces are potential win-win strategies for biodiversity and carbon. Our study shows NbS strategies are not always generalizable across regions. National policies should guide municipalities and cities using regional priorities and science advice, since a NbS promoting biodiversity in one region may, in fact, reduce it in another.


Riikka P Kinnunen  
Institution: Concordia University  
rpkinnunen@gmail.com   


## Development details

This repository hosts the data and code required to create the Quarto Dashboard hosting the interactive results for this manuscript.

### Reproducibility

This project uses [renv](https://rstudio.github.io/renv/articles/renv.html) to 
keep track of the R packages and version of R used in this project. 
This helps to increase the reproducibility of this project by making it easier to 
ensure that different people running this code have the same packages and, more
importantly the same package versions.

### Files

The relevant files are: 

**R Scripts**

- functions.R - Functions to simplify and standardize data preparation and mapping
- prep.R - Workflow to prepare the data for mapping

**Dashboard files**

- index.qmd - The Quarto document for creating the maps and layout
- index.html - The rendered dashboard file for serving (this file can be moved to another hosting platform)
- styles.css - Styles for the grid legend
- custom.scss - Styles for the dashboard

**Other files** 

- test.qmd - A minimal Quarto document for quick tests of the maps
- bivarate_recommendations... - The original descriptive legend image (.png), the Gimp project (.xcf) and the final, minimized descriptive legend image (_grid.png)
- data/* - The data files used (Shape files) and produced (rds files) by this workflow
- data_dl/* - A folder created by these scripts for downloading the Stats Canada city information (see prep.R)
- renv/* and renv.lock - Files used by renv to keep track of R package dependencies used in this project


### Rendering this dashboard

1. **Restore Packages**

    If you are working on this project for the first time, run the following code
    to ensure you have the correct packages/version installed:
    
    ```
    renv::restore()
    ```

2. **Prepare data **

    Run prep.R to prepare/update the city data (alternatively, skip this step and use
    the previously prepared data/cities.rds file)

3. **Render Dashboard**

    Render the index.qmd file by either using the quarto package in R: `quarto::quarto_render("index.qmd")`
    or in the terminal: `quarto render index.qmd`

4. **Serve the Dashboard**

    If on GitHub, ensure that Github pages are set to Build from the main branch: 
    Settings > Pages > Build and deployment

    If on a non-GitHub website, rename and move the index.html file to your website folder. 
    It should appear as https://yourdomain.ca/newname.html.