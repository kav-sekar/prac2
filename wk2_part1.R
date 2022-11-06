#to set diectiry
#setwd("C:/Documents")

A <- 1 #assigning 1 to A <- not = 
B <- 2
C <- A+B
C

ls() #list of objects that are currently active

rm(A) #remove object A

ls() #checking

#structure of a function
#function(object, argument1, argument2, argument3)

#saving function output to a new object
#X<-function(data, argument1, argument2, argument3)

#plot function
#create some datasets, first a vector of 1-100 and 101-200
Data1 <- c(1:100)
Data2 <- c(101:200)
#Plot the data
plot(Data1, Data2, col="red")

#just for fun, create some more, this time some normally distributed
#vectors of 100 numbers
Data3 <- rnorm(100, mean = 53, sd=34)
Data4 <- rnorm(100, mean = 64, sd=14)
#plot
plot(Data3, Data4, col="blue")

#help
?plot

#creating dataframe
df <- data.frame(Data1, Data2)
plot(df, col="green")


#showing tribble
library(tidyverse)
#show the first 10 and then last 10 rows of data in df...
df %>%
  head()
df %>%
  tail()

#format for accessing rows and columns in dataframe
#data.frame[row,column]
df[1:10, 1]
df[5:15,]
df[c(2,3,6),2]
df[,1]

#rename column names
library(dplyr)
df <- df %>%
  dplyr::rename(column1 = Data1, column2=Data2)


#dplyr is a grammar of data manipulation, 
#it has multiple verbs that allow you to change your data into a suitable format. 
#These include select(), filter(), summarise(), which can also be applied to groups in datasets using group_by()

#refer to columns directly by name
df %>% 
  dplyr::select(column1)

#refering to colum name unsing $ operator, which takes the form data.frame$columnName
df$column1

#use the double square bracket operator [[]], and refer to our column by name using quotes
df[["column1"]]


#read csv.into R
LondonDataOSK<- read.csv("prac2_data/LondonData.csv", 
                         header = TRUE, 
                         sep = ",",  
                         encoding = "latin1")

# by default in R, the file path should be defined with / 
#but on a windows file system it is defined with \. 
#Using \\ instead allows R 
#to read the path correctly – alternatively, just use /
LondonDataOSK<- read.csv("prac2_data/LondonData.csv", 
                         header = TRUE, sep = ",", encoding = "latin1")

#straightforward way to read in files using here package
install.packages("here")
library(here)
#Think of here() as a command that is just pointing to a file path, to find out where is pointing use
here::here() 
#This is my working directory for this book project
LondonDataOSK<- read.csv(here::here("prac2_data","LondonData.csv"), 
                         header = TRUE, sep = ",",  
                         encoding = "latin1")

#2.5.3 New skool cleaning
#to clean data as we read 'readr' which also comes bundled as part of the 'tidyverse' package
#read in a .csv file (directly from the web this time — read.csv can do this too) 
#and clean text characters out from the numeric columns before they cause problems

#wang the data in straight from the web using read_csv, 
#skipping over the 'n/a' entries as you go...
LondonData <- read_csv("https://data.london.gov.uk/download/ward-profiles-and-atlas/772d2d64-e8c6-46cb-86f9-e52b4c7851bc/ward-profiles-excel-version.csv",
                       locale = locale(encoding = "latin1"),
                       na = "n/a")


#2.5.4 Examining your new data
#new data has been read in as a data frame / tibble
#check what data type your new data set is, we can use the class() function
class(LondonData)

# or, if you have your old skool data
class(LondonDataOSK)

#use the class() function (from base R) within another two functions summarise_all() 
#(from dplyr) and pivot_longer() (from tidyr) to check that our data has been read in correctly
Datatypelist <- LondonData %>% 
  summarise_all(class) %>%
  pivot_longer(everything(), 
               names_to="All_variables", 
               values_to="Variable_class")
Datatypelist
#we’ve simply grouped all our variables into one LONG column adding another column that contains the class.
#this was to check if all numeric columns have come in as the correct data type

#testing this with loading in data without removing the n/a 
#( reading in LondonData again, but this time without excluding the ‘n/a’)
#LondonData <- read_csv("https://data.london.gov.uk/download/ward-profiles-and-atlas/772d2d64-e8c6-46cb-86f9-e52b4c7851bc/ward-profiles-excel-version.csv", 
#                       locale = locale(encoding = "latin1"))

# quickly edit data, then use edit()
LondonData <- edit(LondonData)

#quickly and easily summarise the data or look at the column headers using
summary(df)

# just look at the head, top5
LondonData%>%
  colnames()%>%
  head()

#2.5.5 Data manipulation in R
#2.5.5.1 Selecting rows
#select just the rows we need by explicitly specifying the range of rows we need
LondonBoroughs<-LondonData[626:658,]

#can also do this with dplyr… with the slice() function, taking a “slice” out of the dataset
LondonBoroughs<-LondonData%>%
  slice(626:658)

#dplyr has a cool function called filter()that let’s you subset rows based on conditions
#filter based on a variable, for example extracting all the wards where female life expectancy is greater than 90
Femalelifeexp<- LondonData %>% 
  filter(`Female life expectancy -2009-13`>90)
Femalelifeexp$`Ward name`

#for character filtering use the function str_detect() 
#from the stringr package in combination with filter() from dplyr
LondonBoroughs<- LondonData %>% 
  filter(str_detect(`New code`, "^E09"))
#to check if it worked
LondonBoroughs$`Ward name`

#That’s also the same as:
LondonBoroughs %>% 
  dplyr::select(`Ward name`) %>%
  print()
#stringr look for (detect!) the rows that have the ward code like E09, 
#then filter these and store in the object LondonBoroughs

#extract only unique rows with distinct(), again from dplyr (since ciity of london appears twice)
LondonBoroughs<-LondonBoroughs %>%
  distinct()

#2.5.5.2 Selecting columns
#select columns if we know which index we want, starting from the first column that’s 1
##select columns 1,19,20 and 21
LondonBoroughs_manualcols<-LondonBoroughs[,c(1,19,20,21)]

#replicate this with dplyr with select()
#select columns 1,19,20 and 21
#The c() function is also used here — this is the ‘combine’ function
LondonBoroughs_dplyrcols<-LondonBoroughs %>%
  dplyr::select(c(1,19,20,21))

#selecting the columns that contain certain words
LondonBoroughs_contains<-LondonBoroughs %>% 
  dplyr::select(contains("expectancy"), 
                contains("obese - 2011/12 to 2013/14"),
                contains("Ward name")) 

#2.5.5.3 Renaming columns
#rename the wards column to boroughs (using rename() like we did earlier), 
#then using the Janitor package tidy everything up
install.packages("janitor")
library(janitor)

LondonBoroughs <- LondonBoroughs %>%
  dplyr::rename(Borough=`Ward name`)%>%
  clean_names()
#By defualt Janitor removes all capitals and uses an underscore wherever there is a space, 
#this would be the same as using setting the case argument to snake

#to now change it every word having a capital letter
#LondonBoroughs <- LondonBoroughs %>%
#  #here the ., means all data
#  clean_names(., case="big_camel")

#2.5.5.4 More dplyr verbs
#determining both:
#the average of male and female life expectancy together
#a normalised value for each# London borough based on the London average
#selecting only the name of the Borough, mean life expectancy and normalised life expectancy,
#arranging the output based on the normalised life expectancy in descending order…
#To do this we will rely on the mutate() function that let’s us add new variables based on existing ones…

Life_expectancy <- LondonBoroughs %>% 
  #new column with average of male and female life expectancy
  mutate(averagelifeexpectancy= (female_life_expectancy_2009_13 +
                                   male_life_expectancy_2009_13)/2)%>%
  #new column with normalised life expectancy
  mutate(normalisedlifeepectancy= averagelifeexpectancy /
           mean(averagelifeexpectancy))%>%
  #select only columns we want
  dplyr::select(new_code,
                borough,
                averagelifeexpectancy, 
                normalisedlifeepectancy)%>%
  #arrange in descending order
  #ascending is the default and would be
  #arrange(normalisedlifeepectancy)
  arrange(desc(normalisedlifeepectancy))
#top of data
slice_head(Life_expectancy, n=5)
#bottom of data
slice_tail(Life_expectancy,n=5)

#2.5.5.5 Levelling up withdplyr
#how does the life expectancy of the London Boroughs compare the the UK average?
#we can use the case_when(), whereby if the value is greater than 
#we can assign the Borough a string of “above UK average”, and if below a string of “below UK average”
Life_expectancy2 <- Life_expectancy %>%
  mutate(UKcompare = case_when(averagelifeexpectancy>81.16 ~ "above UK average",
                               TRUE ~ "below UK average"))
Life_expectancy2
#comparing

#wanted to know the range of life expectancies for London Boroughs that are above the national average
Life_expectancy2_group <- Life_expectancy2 %>%
  mutate(UKdiff = averagelifeexpectancy-81.16) %>%
  group_by(UKcompare)%>%
  summarise(range=max(UKdiff)-min(UKdiff), count=n(), Average=mean(UKdiff))

Life_expectancy2_group
#grouping

#we wanted to have more information based on the distribution of the Boroughs compared to the national average
#work out difference between the life expectancy of the Boroughs compared to the national average
#Round the whole table based on if the column is numeric 
#using across that applies some kind of transformation across the columns selected
Life_expectancy3 <- Life_expectancy %>%
  mutate(UKdiff = averagelifeexpectancy-81.16)%>%
  #Round all numeric columns and the column UKdiff to 0 decimal places
  mutate(across(where(is.numeric), round, 3))%>%
  mutate(across(UKdiff, round, 0))%>%
  #find Boroughs that have an average age of equal to or over 81
  mutate(UKcompare = case_when(averagelifeexpectancy >= 81 ~
                                 #create a new column that contains text based combining
                                 #through the str_c() function from the stringr package that 
                                 #let’s us join two or more vector elements into a single character vector
                                 #sep determines how these two vectors are separated
                                 str_c("equal or above UK average by",
                                       UKdiff, 
                                       "years", 
                                       sep=" "), 
                               TRUE ~ str_c("below UK average by",
                                            UKdiff,
                                            "years",
                                            sep=" ")))%>%
  #Then group by the UKcompare column
  group_by(UKcompare)%>%
  #count the number in each group
  summarise(count=n())

Life_expectancy3


#map the difference between the average life expectancy of each London Borough compared to the UK average
Life_expectancy4 <- Life_expectancy %>%
  mutate(UKdiff = averagelifeexpectancy-81.16)%>%
  mutate(across(is.numeric, round, 3))%>%
  mutate(across(UKdiff, round, 0))

Life_expectancy4

#2.5.6 Plotting
#simple plotting use the plot() function format plot(x_column,y_column)
plot(LondonBoroughs$male_life_expectancy_2009_13,
     LondonBoroughs$percent_children_in_reception_year_who_are_obese_2011_12_to_2013_14)

#2.5.7 Pimp my graph!
#use plotly an open source interactive graphing library
install.packages("plotly")
library(plotly)
plot_ly(LondonBoroughs, 
        #data for x axis
        x = ~male_life_expectancy_2009_13, 
        #data for y axis
        y = ~percent_children_in_reception_year_who_are_obese_2011_12_to_2013_14, 
        #attribute to display when hovering 
        text = ~borough, 
        type = "scatter", 
        mode = "markers")
#touch graph points to see data

#2.5.8 Spatial Data in R
#maptools –– either find and install it using the RStudio GUI or do the following
install.packages("maptools")
#ggplot2 (one of the most influential R packages ever) part of the tidyverse package

#other packages we need to install
install.packages(c("classInt", "tmap"))

# might also need these ones
install.packages(c("RColorBrewer", "sp", "rgeos", 
                   "tmaptools", "sf", "downloader", "rgdal", 
                   "geojsonio"))

#new comment for GIT checking



















