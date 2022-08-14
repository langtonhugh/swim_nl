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

# Add hyperlinks and link to photos.
swim_coords_sf <- swim_coords_sf %>% 
  mutate(Information_link = paste0("<a href = ", Information, "> Latest health information</a>"),
         Photos           = paste0("<img src = ", Photos, ">"))

# Split into official and non-official/
swim_official_sf <- swim_coords_sf %>% 
  filter(Official == "Official outdoor swim spot")

swim_notofficial_sf <- swim_coords_sf %>% 
  filter(Official == "Not official")

# Create popup label because it is the same for both.

# Make list.
swim_list <- list(swim_official_sf, swim_notofficial_sf)

# Paste contents to labels.
swim_list_pastes <- lapply(swim_list, function(x){
  paste0(x$Name            , "<br>",
         x$Entry           , "<br>",
         x$Use             , "<br>",
         x$Official        , "<br>",
         x$Information_link, "<br>",
         x$Photos)
}
)

# Unlist the initial list.
swim_list_labs <- lapply(swim_list_pastes, unlist)

# Unlist again  and split to create character vectors for the popups.
of_popups    <- unlist(swim_list_labs[1])
nonof_popups <- unlist(swim_list_labs[2])

# Amsterdam.
leaflet() %>%
  setView(lng=4.8998371, lat=52.3788467, zoom = 10) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addCircleMarkers(data  = swim_notofficial_sf,
                   popup = nonof_popups,
                   color = "red") %>% 
  addCircleMarkers(data  = swim_official_sf,
                   popup = of_popups,
                   color = "blue")


