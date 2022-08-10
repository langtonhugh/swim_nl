# Load libraries.
library(leaflet)
library(sf)
library(dplyr)
library(osmdata)
library(stringr)
library(readxl)
library(ggplot2)

# Get bounding box for Amsterdam.
ams_query_sf <- getbb(place_name = "Amsterdam Netherlands", format_out = "sf_polygon")

# Output.
class(ams_query_sf)
class(ams_query_sf[[1]])
class(ams_query_sf[[2]]) # that's the one.

ams_sf <- ams_query_sf[[2]]

# Let's keep the bigger one.
ams_real_sf <- ams_sf[2,]

# Load swim locations.
swim_df <- read_excel("data/swim_locations.xlsx")

names(swim_df)
ncol(swim_df)
swim_df[c((2+ncol(swim_df))-2, (2+ncol(swim_df))-3)]

# # Add labels for map.
# swim_labs_df <- as.data.frame(sapply(colnames(swim_df[1:(ncol(swim_df)-2)]),
#                      function(name){ paste(name,swim_df[,name],sep=": ")},
#                      simplify=F))
# 
# 
# swim_coords_df <- bind_cols(
#   swim_labs_df,
#   swim_df[c((2+ncol(swim_df))-2, (2+ncol(swim_df))-3)]
#   )
# 
# # Re-tidy the names.
# names(swim_coords_df) <- gsub("\\.", " ", names(swim_coords_df))

# Make sf.
swim_coords_sf <- swim_df %>% 
  st_as_sf(coords = c(y = "lng", x = "lat"), crs = 4326) 

# # Check.
# ggplot() +
#   geom_sf(data = ams_real_sf) +
#   geom_sf(data = swim_coords_sf)

# Split into official and non-official/
swim_official_sf <- swim_coords_sf %>% 
  filter(Official == "Official swim spot")

swim_notofficial_sf <- swim_coords_sf %>% 
  filter(Official == "Not official swim spot")

# Amsterdam.
leaflet() %>%
  setView(lng=4.8998371, lat=52.3788467, zoom = 11) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addCircleMarkers(data = swim_notofficial_sf,
                   popup = paste0(swim_notofficial_sf$Name   , "<br>",
                                 swim_notofficial_sf$Entry   , "<br>",
                                 swim_notofficial_sf$Use     , "<br>",
                                 swim_notofficial_sf$Official, "<br>",
                                 swim_notofficial_sf$Comments, "<br>",
                                 "<img src = ",
                                 swim_notofficial_sf$Photos,
                                 ">"),
                   color = "red") %>% 
  addCircleMarkers(data = swim_official_sf,
                   popup = paste0(swim_official_sf$Name     , "<br>",
                                  swim_official_sf$Entry    , "<br>",
                                  swim_official_sf$Use      , "<br>",
                                  swim_official_sf$Official , "<br>",
                                  swim_official_sf$Comments , "<br>",
                                  "<img src = ",
                                  swim_official_sf$Photos,
                                  ">"),
                   color = "blue")


