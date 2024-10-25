# Multi-city analysis of synergies and trade-offs between urban bird diversity and carbon storage to inform decision-making 


This README.txt file was generated on 2024-10-21 by Riikka P Kinnunen

Data from Kinnunen et al. "Multi-city analysis of synergies and trade-offs between urban bird diversity and carbon storage to inform decision-making".

Author Information

Principal Investigator Contact Information

```
	Name: Riikka P Kinnunen

	Institution: Concordia University

	Email: rpkinnunen@gmail.com
```

File: bird_diversity_carbon_synergies_and_tradeoffs_2. csv and accompanying shapefile

Modified data used for data analyses. Data was compiled from multiple sources:

eBird data: eBird Basic Dataset. (2022). <https://ebird.org>

Carbon data: Sothe, C., Gonsamu, A., Snider, J., Arabian, J., Kurz, W. A., & Finkelstein, S. (2021). Carbon map and uncertainty in forested areas of Canada, 250m spatial resolution (Version 1) [Data set]. 4TU.ResearchData. <https://doi.org/10.4121/14572929.V1>

Vegetation attributes data: Beaudoin, A., Bernier, P. Y., Villemaire, P., Guindon, L., & Guo, X. J. (2018). Tracking forest attributes across Canada between 2001 and 2011 using a k nearest neighbors mapping approach applied to MODIS imagery. Canadian Journal of Forest Research, 48(1), 85-93. <https://open.canada.ca/data/en/dataset/ec9e2659-1c29-4ddb-87a2-6aced147a990>

Bird life-history data for functional diversity analyses:
Myhrvold, P. N., Baldridge, E., Chan, B., Sivam, D., L. Freeman, D., & Ernest, S. K. M. (2016). An amniote life-history database to perform comparative analyses with birds, mammals, and reptiles (Version 1). Wiley. <https://doi.org/10.6084/m9.figshare.c.3308127.v1> 

Tobias, J. A., Sheard, C., Pigot, A. L., Devenish, A. J., Yang, J., Sayol, F., ... & Schleuning, M. (2022). AVONET: morphological, ecological and geographical data for all birds. Ecology Letters, 25(3), 581-597.
The AVONET dataset and all code for figures and analyses in this manuscript are archived on Figshare <https://figshare.com/s/b990722d72a26b5bfead>

Urban area boundary:
Statistics Canada. Population Centre boundary files. <https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21>


Geographic location: Canada


Columns

uniq_id: ID of grid

pcname: Name of population centre. Corresponds to the name in Statistics Canada Census data and Population Centre Boundary File shapefiles.

slope: Accumulation curve slope obtained using R package KnowBR to assess survey completeness of eBird species inventories across cities.

completeness: Completeness percentage (the percentage representing the observed number
of bird species against the predicted one) obtained from KnowBR that can be used to estimate the grids with reliable eBird survey completeness.

ratio: Ratio between the number of eBird records and the observed bird species obtained using R package KnowBR.

tl_ckl: The number of eBird checklists per grid. Calculated using R Statistical Software.

prd_rch: Predicted bird species richness for each grid obtained from KnowBR.

sp_rich: Bird species richness for each grid. Calculated using R Statistical Software.

sp_ab: Bird species abundance. The total number of individuals per grid. Calculated using R Statistical Software.

sp_div: Bird species diversity. Shannon diversity index (for each grid) calculated using R package vegan.

f_ric: Bird functional richness. Calculated using R package FD. 

ql_f_ri: Quality of functional richness.  Calculated using R package FD.

f_eve: Bird functional evenness. Calculated using R package FD. 

f_div: Bird functional divergence. Calculated using R package FD.

canopy_mn: Mean canopy cover. Mean of the percent crown closure values in each grid.

canopy_sd: Standard deviation of canopy cover. SD of all percent crown closure values in each grid.

canopy_md: Mode canopy cover. Most common percent crown closure value in each grid.

age_mn: Mean tree stand age. Mean tree stand age (mean age of the leading species of polygons in years) in each grid.
 
age_sd: Standard deviation of tree stand age. SD of tree stand age (mean age of the leading species of polygons in years) values in each grid.

age_md: Mode of tree stand age. Most common tree stand age (mean age of the leading species of polygons in years) value in each grid.

height_mn: Mean tree stand height. Mean tree stand height (mean height of the leading species of polygons in meters) in each grid.

height_sd: Standard deviation of tree stand height. SD of tree stand height (mean height of the leading species of polygons in years)values in each grid.

height_md: Mode of tree stand height. Most common tree stand height (mean height of the leading species of polygons in years) value in each grid.

nlsp_mn: Mean percentage of needle-leaved tree species. Mean percent composition of all needle-leaved species. 

nlsp_sd: Standard deviation of needle-leaved tree species. SD of the percent composition of all needle-leaved tree species. 

nlsp_md: Mode of needle-leaved tree species. Most common percent composition value of all needle-leaved tree species. 

blsp_mn: Mean percentage of broad-leaved tree species. Mean percent composition of all broad-leaved species. 

blsp_sd: Standard deviation of broad-leaved tree species. SD of the percent composition of all broad-leaved tree species. 

blsp_md: Mode of broad-leaved tree species. Most common percent composition value of all broad-leaved tree species. 

total_trees: Total percent composition of all broad-leaved and needle-leaved tree species (total trees = total broad-leaved + total needle-leaved species) 

prop_blsp: Proportion of broad-leaved species. The proportion of broad-leaved tree species in each grid.

prop_nlsp: Proportion of needle-leaved species. The proportion of needle-leaved tree species in each grid.

crb_mn: Mean carbon. Mean above-ground forest carbon (kg C/m²) in each grid. Modified from a recently published high-resolution map of Canada's terrestrial carbon stocks (Sothe et al., 2022). 

crb_sm: Total carbon. Total above-ground forest carbon (kg C/m²) in each grid. Modified from a recently published high-resolution map of Canada's terrestrial carbon stocks (Sothe et al., 2022). 












