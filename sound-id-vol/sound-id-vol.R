library(tidyverse)
library(lubridate)
library(magrittr)

media_csv_names <- list.files(path = "sound-id-vol/",
                              pattern = "ML_*",
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

# getting most active state (audio-wise) for each observer
temp <- data0 %>% 
  group_by(FULL.NAME) %>% 
  count(STATE) %>% 
  arrange(desc(n)) %>% 
  slice(1) %>% 
  transmute(FULL.NAME = FULL.NAME,
            ACTIVE.STATE = STATE)

data1 <- data0 %>% 
  group_by(FULL.NAME) %>% 
  summarise(TOT.AUDIO = n(), # each row in the data is one recording
            SP.AUDIO = n_distinct(COMMON.NAME)) %>% 
  left_join(temp) %>% 
  arrange(ACTIVE.STATE, desc(TOT.AUDIO), desc(SP.AUDIO))

# setting 150 species and 400 recordings as threshold
data2 <- data1 %>% 
  filter(TOT.AUDIO >= 400, SP.AUDIO >= 150)

write_csv(data2, "sound-id-vol/sound-id-vol_candidate-list.csv")


