library(tidyverse)
library(magrittr)

load("EBD/ebd_IN_relDec-2021.RData")

# species
data1 <- data %>% 
  mutate(CATEGORY = case_when(CATEGORY == "domestic" & 
                                COMMON.NAME == "Rock Pigeon" ~ "species",
                              TRUE ~ CATEGORY))

gc()

data1 <- data1 %>% 
  filter(APPROVED == 1,
         CATEGORY %in% c("species", "issf")) %>% 
  summarise(SPECIES = n_distinct(COMMON.NAME))

gc()

# observations
data2 <- data %>% 
  summarise(OBSERVATIONS = n()/1000000)

data0 <- data %>% 
  group_by(SAMPLING.EVENT.IDENTIFIER) %>% 
  slice(1)

datax <- cbind(data1, data2)
save(datax, file = "Mittal/IN_coverage_datax.RData")
rm(list = setdiff(ls(), "data0"))
gc()


# locations
data3 <- data0 %>% 
  ungroup() %>% 
  summarise(LOCATIONS = n_distinct(LOCALITY))
  
# lists
data4 <- data0 %>%
  ungroup() %>% 
  summarise(LISTS = n_distinct(SAMPLING.EVENT.IDENTIFIER))
# complete lists
data5 <- data0 %>% 
  ungroup() %>% 
  filter(ALL.SPECIES.REPORTED == 1) %>%
  summarise(C.LISTS = n_distinct(SAMPLING.EVENT.IDENTIFIER))
# unique lists with media
data6 <- data0 %>% 
  group_by(GROUP.ID) %>% 
  filter(any(HAS.MEDIA == 1)) %>% 
  ungroup()  %>%
  summarise(M.LISTS = n_distinct(GROUP.ID))

# cumulative birding hours
data7 <- data0 %>% 
  ungroup() %>% 
  filter(ALL.SPECIES.REPORTED == 1,
         !is.na(DURATION.MINUTES)) %>% 
  summarise(HOURS = round(sum(DURATION.MINUTES)/60, 1))
  

# people
groupaccs <- read.csv("group-accounts/ebd_users_GA_relSep-2021.csv", 
                      na.strings = c(""," ",NA), quote = "", header = T, 
                      nrows = 401) %>% # excluding empty cells
  mutate(CATEGORY = case_when(GA.1 == 1 ~ "GA.1", 
                              GA.2 == 1 ~ "GA.2", 
                              TRUE ~ "NG"))
filtGA <- groupaccs %>% 
  filter(CATEGORY == "GA.1") %>% 
  select(OBSERVER.ID)

data8 <- data0 %>% 
  ungroup() %>% 
  anti_join(filtGA) %>% 
  summarise(PEOPLE = n_distinct(OBSERVER.ID))

datay <- cbind(data3, data4, data5, data6, data7, data8)
save(datay, file = "Mittal/IN_coverage_datay.RData")
rm(list = setdiff(ls(), "data0"))

# states/UTs
data9 <- data0 %>% 
  ungroup() %>% 
  summarise(STATES = n_distinct(STATE),
            DISTRICTS = n_distinct(COUNTY))

load("Mittal/IN_coverage_datax.RData")
load("Mittal/IN_coverage_datay.RData")

dataz <- cbind(datax, datay, data9)

save(dataz, file = "Mittal/IN_coverage_relDec-2021.RData")
write_csv(dataz, "Mittal/IN_coverage_relDec-2021.csv")
