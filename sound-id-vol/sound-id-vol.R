library(tidyverse)
library(lubridate)
library(magrittr)

media_csv_names <- list.files(path = "sound-id-vol/",
                              pattern = "*.csv",
                              full.names = T)

eBird.users <- read.delim("EBD/ebd_users_relDec-2021.txt", sep = "\t", header = T, quote = "", 
                          stringsAsFactors = F, na.strings = c(""," ",NA))
names(eBird.users) <- c("OBSERVER.ID","FIRST.NAME","LAST.NAME")
eBird.users <- eBird.users %>% transmute(OBSERVER.ID = OBSERVER.ID,
                                         FULL.NAME = paste(FIRST.NAME, LAST.NAME))

data0 <- media_csv_names %>% 
  lapply(read_csv) %>% 
  bind_rows() %>% 
  rename(SAMPLING.EVENT.IDENTIFIER = `eBird Checklist ID`,
         FULL.NAME = Recordist) %>%
  rename_with(~ toupper(.)) %>% 
  rename_with(~ gsub(" ", ".", .x)) %>% 
  left_join(eBird.users)

data1 <- data0 %>% 
  group_by(FULL.NAME) %>% 
  summarise(TOT.AUDIO = n(),
            SP.AUDIO = n_distinct(COMMON.NAME)) %>% 
  arrange(desc(TOT.AUDIO), desc(SP.AUDIO))

data2 <- data1 %>% 
  filter(TOT.AUDIO >= 500, SP.AUDIO >= 200)

data3 <- data1 %>% 
  filter(TOT.AUDIO >= 200, SP.AUDIO >= 100)

