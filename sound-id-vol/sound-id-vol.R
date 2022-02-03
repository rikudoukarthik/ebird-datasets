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
  left_join(eBird.users) %>% 
  filter(TAXON.CATEGORY %in% c("Species", "Form"))

# getting most active state (audio-wise) for each observer
temp <- data0 %>% 
  group_by(FULL.NAME) %>% 
  count(STATE) %>% 
  arrange(desc(n)) %>% 
  slice(1) %>% 
  select(FULL.NAME, STATE)

data1 <- data0 %>% 
  group_by(FULL.NAME, STATE) %>% 
  summarise(STATE.TOTAL = n(),
            STATE.SP = n_distinct(COMMON.NAME)) %>% 
  summarise(STATE = STATE,
            STATE.TOTAL = STATE.TOTAL,
            STATE.SP = STATE.SP,
            NATION.TOTAL = sum(STATE.TOTAL),
            NATION.SP = sum(STATE.SP)) %>% 
  right_join(temp) %>% 
  arrange(FULL.NAME, desc(NATION.TOTAL), desc(NATION.SP)) %>% 
  # setting 100 recordings and 50 species as threshold
  filter(STATE.TOTAL >= 60, STATE.SP >= 30,
         NATION.TOTAL >= 100, NATION.SP >= 50) %>% 
  # removing certain people
  filter(!(
    FULL.NAME %in% c("Josep del Hoyo", "Peter Boesman", "Andrew Spencer", "Ben F. King",
                     "Anonymous", 
                     "Ashwin Viswanathan", "Mittal Gala", "Subhadra Devi", "Praveen J", "Karthik Thrikkadeeri", "swaroop patankar", "Suhel Quader", # BCI
                     "Puja Sharma", "Ramit Singal", "Esha Munshi")))

# top 2 by total uploads
data2 <- data1 %>% 
  group_by(STATE) %>% 
  arrange(desc(NATION.SP)) %>% 
  slice(1:3)

# top 2 by total species
data3 <- data1 %>% 
  group_by(STATE) %>% 
  anti_join(data2) %>% 
  arrange(desc(NATION.TOTAL)) %>% 
  slice(1:3)

# joining to get top 4 (if above the threshold) for every state
data4 <- full_join(data2, data3) %>% 
  arrange(STATE, desc(NATION.SP), desc(NATION.TOTAL)) %>% 
  group_by(STATE) %>% 
  slice(1:4)

write_csv(data4, "sound-id-vol/sound-id-vol_candidate-list.csv")
