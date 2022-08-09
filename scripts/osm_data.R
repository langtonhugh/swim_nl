# Load libraries.
library(osmdata)
library(dplyr)
library(ggplot2)
library(sf)


# Get bounding box.
ams_query_sf <- getbb(place_name = "Amsterdam Netherlands", format_out = "sf_polygon")

# Output.
class(ams_query_sf)
class(ams_query_sf[[1]])
class(ams_query_sf[[2]]) # that's the one.

ams_sf <- ams_query_sf[[2]]

# Plot.
ggplot(data = ams_sf) +
  geom_sf(fill = "black", alpha = 0.7)

# Note that there are actually two polygons here.
ggplot() +
  geom_sf(data = ams_sf[1,], fill = "grey") +
  geom_sf(data = ams_sf[2,], fill = "red", alpha = 0.3)

# Let's keep the bigger one.
ams_real_sf <- ams_sf[2,]

# Get bb from it.
bb_sf <- st_bbox(ams_real_sf)
  
# Make query.
water_sf <- opq(bbox = bb_sf) %>% 
  add_osm_feature(key = 'natural', value = 'water') %>%
  osmdata_sf() 

# Check output.
water_poly_sf <- water_sf$osm_polygons

# Plot.
ggplot() +
  geom_sf(data = ams_real_sf) +
  geom_sf(data = water_poly_sf, fill = "blue", colour = "transparent")

# Identify the canal. It is not named.
# We know from manual inspection that the id is 68194453.

# Subset to check if removal would help.
ggplot() +
  geom_sf(data = ams_real_sf) +
  geom_sf(data = filter(water_poly_sf, osm_id != "68194453"),
          fill = "blue", colour = "transparent")

# We don't want to exclude local lakes that fall outside the gemeente, so 
# let's create a buffer.
ams_buf_sf <- st_buffer(ams_real_sf, dist = 1000)

# What does it look like? It'll work.
ggplot() +
  geom_sf(data = ams_buf_sf, fill = "red", alpha = 0.7) +
  geom_sf(data = ams_sf, fill = "black")

# Let's first see if an intersection would work for others too.

# Intersect using the buffer.
ams_water_sf <- water_poly_sf %>% 
  st_intersection(ams_buf_sf)

# Check.
ggplot() +
  geom_sf(data = ams_water_sf, fill = "#83d7ee", col = "#83d7ee") +
  geom_sf(data = ams_real_sf, fill = "transparent") 

# Query to get green spaces.
grass_query_sf <- opq(bbox = bb_sf) %>% 
  add_osm_feature(key = 'landuse', value = 'grass') %>%
  osmdata_sf() 

# Check contents.
grass_sf <- grass_query_sf$osm_polygons

# Plot.
ggplot() +
  geom_sf(data = ams_real_sf) +
  geom_sf(data = grass_sf, fill = "darkgreen", col = "transparent")

# Add forests.
forest_query_sf <- opq(bbox = bb_sf) %>% 
  add_osm_feature(key = 'landuse', value = 'forest') %>%
  osmdata_sf() 

# Check contents.
forest_sf <- forest_query_sf$osm_polygons

# Check everything.
ggplot() +
  geom_sf(data = ams_real_sf) +
  geom_sf(data = grass_sf , fill = "yellowgreen", col = "transparent") +
  geom_sf(data = forest_sf, fill = "forestgreen", col = "transparent") +
  geom_sf(data = ams_water_sf, fill = "#83d7ee" , col = "transparent") 

# Buildings.
building_query_sf <- opq(bbox = bb_sf) %>% 
  add_osm_feature(key = 'building') %>%
  osmdata_sf() 

# Extract polygons.
building_sf <- building_query_sf$osm_polygons

# Plot everything.
ggplot() +
  geom_sf(data = ams_real_sf) +
  geom_sf(data = grass_sf    , fill = "yellowgreen", col = "transparent") +
  geom_sf(data = forest_sf   , fill = "forestgreen", col = "transparent") +
  geom_sf(data = ams_water_sf, fill = "#83d7ee"    , col = "transparent") +
  geom_sf(data = building_sf , fill = "lightgrey"  , col = "transparent") 