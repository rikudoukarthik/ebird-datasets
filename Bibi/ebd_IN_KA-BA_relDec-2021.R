library(tidyverse)

# all India data
load("EBD/ebd_IN_relDec-2021.RData")

# filtering for Bangalore
# removing unnecessary columns
# filtering for only species and identifiable subspecies (including Rock Pigeon)
data0 <- data %>% 
  filter(STATE == "Karnataka",
         COUNTY == "Bangalore") %>% 
  select(-c(LAST.EDITED.DATE, HAS.MEDIA)) %>% 
  mutate(CATEGORY == case_when(CATEGORY == "domestic" & 
                                 COMMON.NAME == "Rock Pigeon" ~ "species",
                               TRUE ~ CATEGORY)) %>% 
  filter(CATEGORY %in% c("issf","species"))

rm(data)

# summarising locations in Bangalore using species richness and total observers
data1 <- data0 %>% 
  group_by(LOCALITY) %>% 
  summarise(SP.RICH = n_distinct(COMMON.NAME),
            TOT.OBSR = n_distinct(OBSERVER.ID)) %>% 
  arrange(desc(TOT.OBSR), desc(SP.RICH))

# list of locations named "park" or "garden" only
data2 <- data1 %>% 
  filter(grepl("Park", LOCALITY) | grepl("park", LOCALITY) |
           grepl("Garden", LOCALITY) | grepl("garden", LOCALITY))


save(data0, file = "Bibi/ebd_IN_KA-BA_relDec-2021.RData")

write_csv(data1, "Bibi/BNG_locations.csv")
write_csv(data2, "Bibi/BNG_locations_park-garden.csv")
