#' IPBES Sustainable Use Assessment - Figure Chapter 3 - Small-scale Fisheries
#' 
#' This R script reproduces the Figure 'Small-scale Fisheries' of the 
#' chapter 3 of the IPBES Sustainable Use Assessment. This figure shows the 
#' global distribution of 350 reviewed studies on small-scale fisheries.
#' 
#' @author Nicolas Casajus <nicolas.casajus@fondationbiodiversite.fr>
#' @date 2022/02/07



## Install `remotes` package ----

if (!("remotes" %in% installed.packages())) install.packages("remotes")


## Install required packages (listed in DESCRIPTION) ----

remotes::install_deps(upgrade = "never")


## Load project dependencies ----

devtools::load_all(".")



## Read IPBES Countries ----

world <- sf::st_read(here::here("data", "ipbes-regions", 
                                "IPBES_Regions_Subregions2.shp"))
# world <- world[which(world$Area != "Antarctica"), ]


## Project in Robinson ----

robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
world <- sf::st_transform(world, robin)


# Create Graticules ----

lat <- c( -90,  -60, -30, 0, 30,  60,  90)
lon <- c(-180, -120, -60, 0, 60, 120, 180)

grat <- graticule::graticule(lons = lon, lats = lat, proj = robin, 
                             xlim = range(lon), ylim = range(lat))


## Data to map ----
## ... a data frame with two columns: 'Country' and 'N of studies'
## ... (in this example)

tab <- readxl::read_xlsx(here::here("data", "countries_SSF_updated.xlsx"), sheet = 1)
tab <- as.data.frame(tab)


## Add Data to Shapefile ----

world$studies <- NA

for (i in 1:nrow(tab)) {
  
  lignes <- which(world$Area == tab[i, "Country"])
  
  # Detect mispelled country name (to be changed in xlsx not the SHP)
  if (!length(lignes)) stop(paste0(i, " : ", tab[i, "Country"]))
  
  world[lignes, "studies"] <- tab[i, "N of studies"]
}


## Define Colors ----

classes <- data.frame(from  = c(0, 1, 1, 4,  9, 15, 20),   # x >  from
                      to    = c(0, 1, 4, 9, 15, 20, 9999), # x <= to
                      label = c("0", "1", "2", "4",  "9", "15", ">20"),
                      color = c("#FFFFFF", "#FFCBFE", "#FF98FD", "#FF63FC", 
                                "#FF00FC", "#CF00C9", "#680064"))

world$color <- NA

for (i in 1:nrow(classes)) {
  
  pos <- which(world[ , "studies", drop = TRUE] >  classes[i, "from"] & 
                 world[ , "studies", drop = TRUE] <= classes[i, "to"])
  
  if (length(pos)) world[pos, "color"] <- classes[i, "color"]
}


# NA values...
pos <- which(is.na(world[ , "studies", drop = TRUE]))
if (length(pos)) world[pos, "color"] <- "#f0f0f0"

# Other colors...
borders <- "#c8c8c8"
texte   <- "#666666"

## Graphical Device ----
## ... 20min to get the PNG ...
# grDevices::png(file = here::here("figures", "map_renato.png"),
#                width = 12, height = 7.5, pointsize = 14, units = "in", 
#                res = 600)

## ...  2min to get the PDF ...
png(here::here("figures", "ipbes-su-chap3-small_scale_fisheries.png"),
    width = 12, height = 7.5, units = "in", res = 600, pointsize  = 18)


## Basemap + Data + Graticules ----

par(mar = rep(1, 4), family = "serif")

sp::plot(grat, lty = 1, lwd = 0.2, col = borders)

plot(sf::st_geometry(world), col = world$"color", border = borders, 
     lwd = 0.2, add = TRUE)


## Legend ----

x_length <- 1000000
x_start  <- -1 * (x_length * (nrow(classes) / 2))

if (nrow(classes) %% 2 != 0) x_start <- x_start - (x_length / 2)

y_height <-    500000
# y_middle <- -10000000
y_middle <- -10500000

par(xpd = TRUE)

for (i in 1:nrow(classes)) {
  
  rect(xleft   = x_start + (i - 1) * x_length, 
       xright  = x_start + i * x_length,
       ybottom = y_middle - y_height, 
       ytop    = y_middle + y_height,
       col     = classes[i, "color"], border = borders)
  
  text(x      = x_start + (i - 1) * x_length, 
       y      = y_middle - y_height, 
       labels = classes[i, "label"],
       pos = 1, cex = 0.9, col = texte)
}


## Title ----

text(x = 0, y = y_middle + y_height, col = texte, font = 2, pos = 3,
     labels = "Small Scale Fisheries: Number of studies per country")

par(xpd = FALSE)

dev.off()
