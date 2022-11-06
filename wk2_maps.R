#Load Packages (ignore any error messages about being built under a 
#different R version):
library(maptools)
library(RColorBrewer)
library(classInt)
library(sp)
library(rgeos)
library(tmap)
library(tmaptools)
library(sf)
library(rgdal)
library(geojsonio)
library(stringr)
library(janitor)
library(dplyr)
library(readr)
library(tidyverse)
#rgdal and rgeos packages used to access spatial data GDAL and GEOS
#maptools package to read shape files
#sp package (along with spdep) 
#very important for defining a series of classes and methods for spatial data natively in R
#raster advanced the analysis of gridded spatial data
#packages like classInt and RColorbrewer facilitated the binning of data and colouring of choropleth maps
#leaflet enables R to interface with the leaflet javascript library for online, dynamic maps
#ggplot2 ued to create graphical objects in R, including maps
#tmap (Thematic Map) package enables us to read, write and manipulate spatial data 
#and produce visually impressive and interactive maps
#sf (Simple Features) package is helping us re-think the way that spatial data can be stored and manipulated

#2.5.8.2 Making some choropleth maps
#Choropleth maps are thematic maps which colour areas according to some phenomenon
#plot() function requires no data preparation but additional effort in colour selection/ adding the map key etc. 
#Quick plot (qplot()) and ggplot() (installed in the ggplot2 package, part of the tidyverse) 
#require some additional steps to format the spatial data but select colours and add keys etc automatically
#Qplot is basically a shortcut for a quick map / plot, but if you have a lot of data use ggplot()

#reading geojson from website
# this will take a few minutes
EW <- st_read("https://opendata.arcgis.com/datasets/8edafbe3276d4b56aec60991cbddda50_2.geojson")

#OR reading geojason locally
# this will take a few minutes
# geojson in local folder
#EW <- st_read(here::here("prac2_data",
#                         "Local_Authority_Districts__December_2015__Boundaries.geojson"))

#OR read shapefile locally
# shapefile in local folder
#EW <- st_read(here::here("prac2_data",
#                         "Local_Authority_Districts_(December_2015)_Boundaries",
#                         "Local_Authority_Districts_(December_2015)_Boundaries.shp"))

#Pull out London using the str_detect() function from the stringr package 
#in combination with filter() from dplyr
#look for district code that relates to London (E09) from the ‘lad15cd’ column data frame of our sf object

LondonMap<- EW %>%
  filter(str_detect(lad15cd, "^E09"))

#plot it using the qtm function
qtm(LondonMap)


#2.5.8.3 Attribute data
#first clean up all of our names with Janitor
#join attribute data to boundaries with merge()

LondonData <- clean_names(LondonData)

#EW is the data we read in straight from the web
BoroughDataMap <- EW %>%
  clean_names()%>%
  # the . here just means use the data already loaded
  filter(str_detect(lad15cd, "^E09"))%>%
  merge(.,
        LondonData, 
        by.x="lad15cd", 
        by.y="new_code",
        no.dups = TRUE)%>%
  distinct(.,lad15cd,
           .keep_all = TRUE)

#distinct() mean we only have unique rows based on the code,
#but we keep all other variables .keep_all=TRUE. 
#If you change to .keep_all=FALSE (which is the default) 
#then all the other variables (the attributes in the columns) will be removed.

#An alternative to merge() would be to use a left_join()
#always use a join type (e.g. left_join()) (e.g. inner, left, right, full). 
#merge() as default is the same as an inner join

#left join if there are multiple matches then all hits are returned
BoroughDataMap2 <- EW %>% 
  clean_names() %>%
  filter(str_detect(lad15cd, "^E09"))%>%
  left_join(., 
            LondonData,
            by = c("lad15cd" = "new_code"))

#after this use filter() and distinct() reduce the data to London,
#and remove the duplicate City of London row afterwards

#2.5.9 Simple mapping
#tmap follows the idea of the grammar of graphics, similar to dplyr being the grammar of data manipulation
#main data being mapped defines the location somewhere on Earth (loaded with tm_shape). 
#Map aesthetics are then defined with a +, these usually include tm_fill() 
#(fill of the polygons based on a variable) + tm_borders() (border of polygons). 
#However, tm_polygon basically combines tm_fill() and tm_borders()
# data first then + aesthetic syntax

#create a choropleth map very quickly now using qtm()
library(tmap)
library(tmaptools)
tmap_mode("plot")
qtm(BoroughDataMap, 
    fill = "rate_of_job_seekers_allowance_jsa_claimants_2015")

#basemap we need to extract it from OpenStreetMap (OSM) using the read_osm()
#function from the tmaptools package
#create a box (termed bounding box) around London using the st_box()
#function from the sf package to extract the basemap image (which is a raster)
install.packages("OpenStreetMap")

tmaplondon <- BoroughDataMap %>%
  st_bbox(.) %>% 
  tmaptools::read_osm(., type = "osm", zoom = NULL)
# now we have base map
#set tmap to plot, add the basemap, add the shape (our London layer), tell it which attribute to map (job seekers), 
#the style to make the colour divisions, the transparency (alpha), compass, scale and legend.
#data from our bounding box + it’s raster aesthetic (tm_rgb) + the data from our London Borough layer 
#and it’s aesthetics. As they are the same place they plot over each other
#style — how to divide the data into out colour breaks
#palette — the colour scheme to use
tmap_mode("plot")

tm_shape(tmaplondon)+
  tm_rgb()+
  tm_shape(BoroughDataMap) + 
  tm_polygons("rate_of_job_seekers_allowance_jsa_claimants_2015", 
              style="jenks",
              palette="YlOrBr",
              midpoint=NA,
              title="Rate per 1,000 people",
              alpha = 0.5) + 
  tm_compass(position = c("left", "bottom"),type = "arrow") + 
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(title = "Job seekers' Allowance Claimants", legend.position = c("right", "bottom"))

#For more palette options, run palette_explorer() in the console

#now try to Merge our Life_expectancy4map with the spatial data EW
#Map our merge with tmap
Life_expectancy4map <- EW %>%
  left_join(., 
             Life_expectancy4,
             by = c("lad15cd" = "new_code"))%>%
  distinct(.,lad15cd, 
           .keep_all = TRUE)
#now mapping this
tmap_mode("plot")

tm_shape(tmaplondon)+
  tm_rgb()+
  tm_shape(Life_expectancy4map) + 
  tm_polygons("UKdiff", 
              style="pretty",
              palette="Blues",
              midpoint=NA,
              title="Number of years",
              alpha = 0.5) + 
  tm_compass(position = c("left", "bottom"),type = "arrow") + 
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(title = "Difference in life expectancy", legend.position = c("right", "bottom"))

#style pretty rounds to whole numbers and evenly spaces them over the data
#Palette controls the colour of the map, you can see more options through tmaptools::palette_explorer()

#2.6 Tidying data
#tidy data is defined using the following three rules:
#Each variable must have its own column.
#Each observation must have its own row.
#Each value must have its own cell.

#So this gives us:
#Put each dataset in a tibble
#Put each variable in a column

#earier we read in flytipping as below
#flytipping <- read_csv("https://data.london.gov.uk/download/fly-tipping-incidents/536278ff-a391-4f20-bc79-9e705c9b3ec0/fly-tipping-borough.csv")

#now we can do this tidy as below
flytipping1 <- read_csv("https://data.london.gov.uk/download/fly-tipping-incidents/536278ff-a391-4f20-bc79-9e705c9b3ec0/fly-tipping-borough.csv", 
                        col_types = cols(
                          code = col_character(),
                          area = col_character(),
                          year = col_character(),
                          total_incidents = col_number(),
                          total_action_taken = col_number(),
                          warning_letters = col_number(),
                          fixed_penalty_notices = col_number(),
                          statutory_notices = col_number(),
                          formal_cautions = col_number(),
                          injunctions = col_number(),
                          prosecutions = col_number()
                        ))
# view the data
View(flytipping1)

#we have a tibble with columns of each varaible (e.g. warning letters, total actions taken) 
#where every row is a London borough.
#We want make sure that each observation has its own row
#it doesn’t as in the first row here we have observations for total incidents and total actions taken etc
#to do this we will use pivot_longer()
#make sure you have latest version of tidyverse

#convert the tibble into a tidy tibble
flytipping_long <- flytipping1 %>% 
  pivot_longer(
    cols = 4:11,
    names_to = "tipping_type",
    values_to = "count"
  )

# view the data
View(flytipping_long)

# you could also use an alternative which just pulls everything out into a single table
flytipping2 <- flytipping1[,1:4]
View(flytipping2)

#make data more suitable for mapping with pivot_wider()by making coloumns for each year of each variable
#note just because data is tidy it may not be appropriate
#pivot the tidy tibble into one that is suitable for mapping
flytipping_wide <- flytipping_long %>% 
  pivot_wider(
    id_cols = 1:2,
    names_from = c(year,tipping_type),
    names_sep = "_",
    values_from = count
  )

View(flytipping_wide)

#if you were just interested in a specific varaible and wanted the coloums to be each year of the data
widefly <- flytipping2 %>% 
  pivot_wider(
    names_from = year, 
    values_from = total_incidents)

View(widefly)

#now join this to the London borough .shp and produce a map

#always try to put your data into a certain format 
#before doing further analysis on it as it will be easier for you to determine the right tools to select.















