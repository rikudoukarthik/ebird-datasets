library(tidyverse)
library(lubridate)
library(dtplyr)
library(data.table)

load("ebd_IN_relAug-2021.RData")

data <- data %>% collect()
rm(data_DT)

data0 <- data %>% group_by(STATE)

data1 <- data0 %>% summarise(LISTS = n_distinct(SAMPLING.EVENT.IDENTIFIER)) %>% arrange(desc(LISTS))
data2 <- data0 %>% filter(ALL.SPECIES.REPORTED == 1) %>%
  summarise(CLISTS = n_distinct(SAMPLING.EVENT.IDENTIFIER)) %>% arrange(desc(CLISTS))
data3 <- data0 %>% summarise(EBIRDERS = n_distinct(OBSERVER.ID)) %>% arrange(desc(EBIRDERS))
data4 <- left_join(data1,data2) %>% left_join(data3)

data4 <- data4 %>% mutate(CLR = round(CLISTS/LISTS, 2), # complete list ratio
                          LPO = round(LISTS/EBIRDERS, 2)) # lists per ebirder

# ranks
data5 <- data.frame(1:36, data1$STATE, data2$STATE, data3$STATE, 
                    arrange(data4, desc(CLR))$STATE, arrange(data4, desc(LPO))$STATE)
names(data5) <- c("RANK","FOR LISTS","FOR CLISTS","FOR EBIRDERS", "FOR CLR", "FOR LPO")

write.csv(data4, "birdingbystate.csv", row.names = F)
write.csv(data5, "birdingbystate_ranks.csv", row.names = F)

rm(list = c("data","data0"), pos = .GlobalEnv)
save.image("birdingbystate.RData")
