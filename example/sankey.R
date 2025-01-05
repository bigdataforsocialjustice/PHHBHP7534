
library(lubridate)
 library(raster)
library(rgeos)
library(sp)
#library(SpNetPrep)
library(spatstat)
library(tigris)
library(graphics)
library(grDevices)
library(maptools)
library(PBSmapping)
library(sp)
library(spatstat)
library(spdep)
library(stats)
library(utils)
library(treemap)
library(RSocrata)
library(maptools)
library(stringr)
library(dplyr)
library(RColorBrewer)
pacman::p_load(
  networkD3,
  tidyverse)

base_url = "https://data.lacity.org/resource/2nrs-mtv8.json?" #this is 2020 to present

#to get a token for your own app go to https://opendata.socrata.com/login which is good for any site using socrata
my_token <- "w0BkWUPZYzjQRwNEVX8KEijw4"
lacity_data2020 <- read.socrata(base_url, my_token)
glimpse(lacity_data2020)

#base_url = https://data.lacity.org/resource/63jg-8b9z.json
lacity_data2019 <- read.socrata(base_url, my_token)
glimpse(lacity_data2019)

lacity_data2019_sub <- lacity_data2019 %>%
  dplyr::select(dr_no, date_occ, time_occ, area, area_name, premis_desc, weapon_desc, status_desc,
                crm_cd_desc, mocodes, vict_age, vict_descent, vict_sex, lat, lon)
lacity_data2020_sub <- lacity_data2020 %>%
  dplyr::select(dr_no, date_occ, time_occ, area, area_name, premis_desc, weapon_desc, status_desc,
                crm_cd_desc, mocodes, vict_age, vict_descent, vict_sex, lat, lon)

lacity_data <- rbind(lacity_data2019_sub, lacity_data2020_sub)

treemap_df <-
  lacity_data %>%
  #dplyr::filter(str_detect(crm_cd_desc, "CHILD NEGLECT|CHILD ABUSE|INTIMATE PARTNER")) %>%
  dplyr::filter(str_detect(crm_cd_desc, "CHILD NEGLECT|CHILD ABUSE")) %>%
  dplyr::group_by(area_name, crm_cd_desc) %>%
  dplyr::summarize(n = n())

treemap(treemap_df,
        index=c("area_name","crm_cd_desc"),
        vSize="n",
        type="index",
        fontsize.labels=c(15,12),
        fontcolor.labels=c("white","orange"),
        fontface.labels=c(2,1),
        bg.labels=0,
        align.labels=list(
          c("center", "center"),
          c("center", "top")
        ),
        overlap.labels=0.2,
        inflate.labels=T
)

private_abuse_in_la <- lacity_data %>%
  dplyr::mutate(vict_age = as.numeric(vict_age)) %>%
  dplyr::filter(str_detect(crm_cd_desc, "CHILD NEGLECT|CHILD ABUSE"),
                str_detect(premis_desc, "GROUP HOME|MOTEL|DWELLING|RESIDENTIAL|RESIDENCE|HOUSING|CONDOMINIUM|VACATION")) %>%
  #dplyr::mutate(crm_cd_desc = str_replace(crm_cd_desc, ".*INTIMATE PARTNER.*", "IPV")) %>%
  dplyr::mutate(crm_cd_desc = str_replace(crm_cd_desc, ".*CHILD ABUSE.*", "CPA")) %>%
  dplyr::mutate(crm_cd_desc = str_replace(crm_cd_desc, ".*NEGLECT.*", "CN")) %>%
  dplyr::select("dr_no", "crm_cd_desc", "date_occ", "time_occ",  "lat", "lon", "mocodes","area_name",  "vict_age", "vict_sex", "vict_descent", "premis_desc", "weapon_desc", "status_desc")

crimebyarea <-  private_abuse_in_la  %>%
  dplyr::group_by(crm_cd_desc, area_name) %>%
  dplyr::summarise(count= n())

crimebyarea

public_abuse_in_la <- lacity_data %>%
  filter(!dr_no %in% private_abuse_in_la$dr_no ) %>%
  dplyr::filter(str_detect(crm_cd_desc, "CHILD NEGLECT|CHILD ABUSE")) %>%
  dplyr::mutate(vict_age = as.numeric(vict_age)) %>%
  #dplyr::mutate(crm_cd_desc = str_replace(crm_cd_desc, ".*INTIMATE PARTNER.*", "IPV")) %>%
  dplyr::mutate(crm_cd_desc = str_replace(crm_cd_desc, ".*CHILD ABUSE.*", "CPA")) %>%
  dplyr::mutate(crm_cd_desc = str_replace(crm_cd_desc, ".*NEGLECT.*", "CN")) %>%
  dplyr::select("dr_no", "crm_cd_desc", "date_occ", "time_occ",  "lat", "lon", "mocodes","area_name",  "vict_age", "vict_sex", "vict_descent", "premis_desc", "weapon_desc", "status_desc")

crimebyarea <-  public_abuse_in_la  %>%
  dplyr::group_by(crm_cd_desc, area_name) %>%
  dplyr::summarise(count= n())

public_abuse_in_la$mo <- public_abuse_in_la$mocodes

library(tidyr)
ipv_crime_mo <- separate(data = public_abuse_in_la, col = mocodes, into =
                           c("m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10"),
                         sep = " ")

# makes all "m" variables numeric at once
ipv_crime_mo[,7:16] <- sapply(ipv_crime_mo[,7:16],as.numeric)
glimpse(ipv_crime_mo)

tbl_lookup<-read.csv("C:/Users/barboza-salerno.1/OneDrive - The Ohio State University/Desktop/Research/LA County/MO_CODES_Numerical_20180627.csv")
names(tbl_lookup)[1] <- "id"

for (i in 1:10)
{
  ipv_crime_mo[,(length(ipv_crime_mo)+1)] = tbl_lookup[match(ipv_crime_mo[,(i+6)], tbl_lookup$id), "descript"]
}

library(writexl)
write_xlsx(ipv_crime_mo, "C:/Users/barboza-salerno.1/Downloads/ipv_pub_crime_mo__11_19_2023.xlsx")



crimebyarea_pub <-  public_abuse_in_la  %>%
  dplyr::group_by(crm_cd_desc, area_name) %>%
  dplyr::summarise(count= n())

crimebyarea
#############################################################
library(dplyr)
table(public_abuse_in_la$premis_desc)[order(table(public_abuse_in_la$premis_desc),decreasing = TRUE)]

sankey_df <- public_abuse_in_la %>%
  dplyr::select(premis_desc, vict_age) %>%
  drop_na(.) %>%
  filter(premis_desc == "STREET" |
           premis_desc == "SIDEWALK" |
           premis_desc == "PARKING LOT" |
           premis_desc == "ELEMENTARY SCHOOL" |
           premis_desc == "VEHICLE, PASSENGER/TRUCK" |
           premis_desc == "PARK/PLAYGROUND") %>%
  mutate(age_cat = case_when(
    vict_age <= 3 ~ "0 to 3",
    vict_age >3 & vict_age <=6 ~  "4 to 6",
    vict_age > 6 & vict_age <=10 ~ "7 to 10",
    vict_age > 10 & vict_age <=15 ~  "11 to 15",
    vict_age > 15 & vict_age <=18 ~  "16 to 18"
  )) %>% dplyr::select(-vict_age) %>%
  group_by(premis_desc, age_cat ) %>%
  count(premis_desc) %>%
  drop_na(.) %>%
  rename(source = age_cat,
         target = premis_desc)

# The unique node names
nodes <- data.frame(
  name=c(as.character(sankey_df$source), as.character(sankey_df$target)) %>%
    unique()
)

nodes  # print

# match to numbers, not names
sankey_df$IDsource <- match(sankey_df$source, nodes$name)-1
sankey_df$IDtarget <- match(sankey_df$target, nodes$name)-1

# plot
######

sankey.colors <- 'd3.scaleOrdinal() .domain(["0 to 3", "11 to 15","4 to 6",
"7 to 10"]) .range(["deepskyblue", "mediumpurple", "mediumpurple", "red",
"red", "hotpink", "orange", "yellowgreen"])'

p <- sankeyNetwork(
  Links = as.data.frame(sankey_df),
  Nodes = nodes,
  Source = "IDsource",
  Target = "IDtarget",
  Value = "n",
  NodeID = "name",
  units = "TWh",
  fontSize = 12,
  colourScale = sankey.colors,
  nodeWidth = 30,
  iterations = 0)        # ensure node order is as in data
p

sankey_df1 <- public_abuse_in_la %>%
  dplyr::select(premis_desc,   crm_cd_desc) %>%
  filter(premis_desc == "STREET" |
           premis_desc == "SIDEWALK" |
           premis_desc == "PARKING LOT" |
           premis_desc == "ELEMENTARY SCHOOL" |
           premis_desc == "VEHICLE, PASSENGER/TRUCK" |
           premis_desc == "PARK/PLAYGROUND") %>%

  drop_na(.) %>%
  group_by( premis_desc, crm_cd_desc ) %>%
  count(premis_desc, crm_cd_desc) %>%
  rename(source = premis_desc,
         target = crm_cd_desc)

# combine links
links <- bind_rows(sankey_df, sankey_df1)

# The unique node names
nodes <- data.frame(
  name=c(as.character(links$source), as.character(links$target)) %>%
    unique()
)

# Create id numbers
links$IDsource <- match(links$source, nodes$name)-1
links$IDtarget <- match(links$target, nodes$name)-1

# plot
######
p <- sankeyNetwork(Links = as.data.frame(links),
                   Nodes = nodes,
                   Source = "IDsource",
                   Target = "IDtarget",
                   Value = "n",
                   NodeID = "name",
                   units = "TWh",
                   fontSize = 12,
                   colourScale = sankey.colors,
                   nodeWidth = 30,
                   iterations = 0)
p
