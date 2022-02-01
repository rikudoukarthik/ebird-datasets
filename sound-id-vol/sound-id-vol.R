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
  select(FULL.NAME, STATE)

data1 <- data0 %>% 
  right_join(temp) %>% 
  group_by(FULL.NAME, STATE) %>% 
  # counts for each observer's active state only
  summarise(TOT.AUDIO = n(), # each row in the data is one recording
            SP.AUDIO = n_distinct(COMMON.NAME)) %>% 
  ungroup() %>% 
  arrange(STATE, desc(TOT.AUDIO), desc(SP.AUDIO)) %>% 
  # setting 50 species and 100 recordings as threshold
  filter(TOT.AUDIO >= 100, SP.AUDIO >= 50) %>% 
  # removing certain people
  filter(!(
    FULL.NAME %in% c("Josep del Hoyo", "Peter Boesman", "Andrew Spencer",
                     "Anonymous", 
                     "Ashwin Viswanathan", "Mittal Gala", "Subhadra Devi", "Praveen J", "Karthik Thrikkadeeri", "swaroop patankar", "Suhel Quader", # BCI
                     "Puja Sharma", "Ramit Singal", "Esha Munshi")))

# top 2 by total uploads
data2 <- data1 %>% 
  group_by(STATE) %>% 
  arrange(desc(TOT.AUDIO)) %>% 
  slice(1:2)

# top 2 by total species
data3 <- data1 %>% 
  group_by(STATE) %>% 
  arrange(desc(SP.AUDIO)) %>% 
  slice(1:2)

# joining to get top 4 (if above the threshold) for every state
data4 <- full_join(data2, data3) %>% 
  arrange(STATE, desc(TOT.AUDIO), desc(SP.AUDIO))

write_csv(data4, "sound-id-vol/sound-id-vol_candidate-list.csv")
