library(tidyverse)
library(lubridate)


# ensure .RData is in the directory
load("EBD/ebd_IN_relSep-2021.RData") # 3 minutes
data <- data %>% select(OBSERVER.ID) %>% distinct()

eBird_users <- read.delim("EBD/ebd_users_relJun-2021.txt", sep = "\t", header = T, quote = "",
                          stringsAsFactors = F, na.strings = c(""," ",NA))
eBird_users <- eBird_users %>% transmute(OBSERVER.ID = observer_id,
                                         FULL.NAME = paste(first_name, last_name, sep = " "))
data0 <- left_join(data, eBird_users)


# textual filters for group accounts

data1 <- data0 %>% 
  filter(grepl("Group",FULL.NAME) | grepl("group",FULL.NAME) | #83
           grepl("Survey",FULL.NAME) | grepl("survey",FULL.NAME) | #98
           grepl("Atlas",FULL.NAME) | grepl("atlas",FULL.NAME) | #108
           grepl("rganization",FULL.NAME) | grepl("rganisation",FULL.NAME) | #108
           grepl("oundation",FULL.NAME) | grepl("AWC",FULL.NAME) | grepl("awc",FULL.NAME) | #128
           grepl("Census",FULL.NAME) | grepl("census",FULL.NAME) | #132
           grepl("Bird",FULL.NAME) | grepl("bird",FULL.NAME) | #248 ###
           grepl("Count",FULL.NAME) | grepl("count",FULL.NAME) | #255
           grepl("niversity",FULL.NAME) | grepl("ollege",FULL.NAME) | #275
           (grepl("Centre",FULL.NAME) | grepl("Center",FULL.NAME) | 
              grepl("centre",FULL.NAME) | grepl("center",FULL.NAME)) | #277
           grepl("School",FULL.NAME) | grepl("school",FULL.NAME) | #298
           grepl("Club",FULL.NAME) | grepl("club",FULL.NAME) | #307
           (grepl("City",FULL.NAME) | grepl("city",FULL.NAME) | 
              grepl("State",FULL.NAME) | grepl("state",FULL.NAME)) | #311
           grepl("202",FULL.NAME) | grepl("201",FULL.NAME)| grepl("200",FULL.NAME) | #323
           grepl("rnitholog",FULL.NAME) | grepl("arathon",FULL.NAME) | #324
           grepl("ociety",FULL.NAME) | grepl("istoric",FULL.NAME) | #348
           grepl("nstitut",FULL.NAME) | grepl("etwork",FULL.NAME) | #352
           grepl("Team",FULL.NAME) | grepl("team",FULL.NAME) | #364
           grepl("estival",FULL.NAME) | grepl("Fest",FULL.NAME) | grepl("fest",FULL.NAME) | #364
           grepl("esearch",FULL.NAME) | grepl("ecord",FULL.NAME) | #368
           grepl("roject",FULL.NAME) | grepl("iodivers",FULL.NAME) | #378
           grepl("ational",FULL.NAME) | grepl("eserve",FULL.NAME) | #383
           grepl("rotect",FULL.NAME) | grepl("Lodge",FULL.NAME) | grepl("lodge",FULL.NAME) | #385
           grepl("esort",FULL.NAME) | grepl("anctuary",FULL.NAME) | grepl("ildlife",FULL.NAME) | #395
           grepl("epartment",FULL.NAME) | grepl("Dept",FULL.NAME) | grepl("dept",FULL.NAME) | #397
           grepl("onservation",FULL.NAME) | grepl("Trust",FULL.NAME) | grepl("trust",FULL.NAME) | #400 
           grepl("ollect",FULL.NAME)
  )

write.csv(data1, "group-accounts/ebd_users_GA_relSep-2021_0.csv")


# will modify the .csv by adding columns for GA.1 and GA.2 and assigning the values with 
# justifications