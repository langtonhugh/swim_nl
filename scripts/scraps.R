leaflet() %>%
  setView(lng=4.8998371, lat=52.3788467, zoom = 11) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addCircleMarkers(data = swim_notofficial_sf,
                   popup = paste0(swim_notofficial_sf$Name            , "<br>",
                                  swim_notofficial_sf$Entry           , "<br>",
                                  swim_notofficial_sf$Use             , "<br>",
                                  swim_notofficial_sf$Official        , "<br>",
                                  swim_notofficial_sf$Information_link, "<br>",
                                  swim_notofficial_sf$Photos),
                   color = "red") %>% 
  addCircleMarkers(data = swim_official_sf,
                   popup = paste0(swim_official_sf$Name     , "<br>",
                                  swim_official_sf$Entry    , "<br>",
                                  swim_official_sf$Use      , "<br>",
                                  swim_official_sf$Official , "<br>",
                                  swim_notofficial_sf$Information_link, "<br>",
                                  swim_official_sf$Photos),
                   color = "blue")


old <- paste0(swim_official_sf$Name            , "<br>",
              swim_official_sf$Entry           , "<br>",
              swim_official_sf$Use             , "<br>",
              swim_official_sf$Official        , "<br>",
              swim_official_sf$Information_link, "<br>",
              swim_official_sf$Photos)

new <- swim_list_labs["swim_official_sf"]

class(old)
length(old)
old[[2]]
class(new)

new2 <- unlist(new)

class(new2)

old == new2
