library(tidyverse)

load("EBD/ebd_IN_relJan-2022.RData")


eBird_users <- read.delim("EBD/ebd_users_relDec-2021.txt", sep = "\t", header = T, 
                          quote = "", stringsAsFactors = F, na.strings = c(""," ",NA))
eBird_users <- eBird_users %>% 
  transmute(OBSERVER.ID = observer_id,
            FULL.NAME = paste(first_name, last_name, sep = " "))


# list of group accounts to be filtered
groupaccs <- read_csv("group-accounts/ebd_users_GA_relDec-2021.csv")  
groupaccs <- groupaccs %>% 
  mutate(CATEGORY = case_when(GA.1 == 1 ~ "GA.1", GA.2 == 1 ~ "GA.2", TRUE ~ "NG"))
filtGA <- groupaccs %>% 
  # both categories need to be filtered because this is birder-related 
  filter(CATEGORY == "GA.1" | CATEGORY == "GA.2") %>% 
  select(OBSERVER.ID)



data1 <- data %>% 
  filter(CATEGORY %in% c("species", "issf")) %>% 
  group_by(OBSERVER.ID) %>% 
  summarise(NO.SP = n_distinct(COMMON.NAME)) %>% 
  left_join(eBird_users) %>% 
  anti_join(filtGA) %>% 
  arrange(desc(NO.SP)) %>% 
  slice(1:500)

data2 <- data %>% 
  filter(ALL.SPECIES.REPORTED == 1, PROTOCOL.TYPE != "Incidental") %>% 
  group_by(OBSERVER.ID) %>% 
  summarise(NO.LISTS = n_distinct(SAMPLING.EVENT.IDENTIFIER)) %>% 
  left_join(eBird_users) %>% 
  anti_join(filtGA) %>% 
  arrange(desc(NO.LISTS)) %>% 
  slice(1:500)


write_csv(data1, file = "Mittal/top500_species.csv")
write_csv(data2, file = "Mittal/top500_lists.csv")
