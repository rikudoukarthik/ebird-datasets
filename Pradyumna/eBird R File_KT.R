library(tidyverse)
library(lubridate)

bang_urb <- read.delim("Pradyumna/ebd_IN-KA-BN_relAug-2021.txt", 
                       sep = "\t", # what character is used as separator (in this case in .txt, tab)
                       header = T, # whether the input file contains a header row (with column names)
                       quote = "", # what symbol to use to quote character values in data (in this case, none)
                       stringsAsFactors = F, # whether to convert character values to factor (alternatively, use as.is=T)
                       na.strings = c(""," ",NA)) # what values to consider as NA

bang_urb2 <- bang_urb %>% 
  mutate(OBSERVATION.DATE = as.Date(OBSERVATION.DATE), # convert string to date
         YEAR = year(OBSERVATION.DATE), # retrieve year from date
         MONTH = month(OBSERVATION.DATE), # retrieve month from date
         DAYM = day(OBSERVATION.DATE), # retrieve day-of-month from date
         DAYY = yday(OBSERVATION.DATE)) # retrieve day-of-year from date

count(bang_urb2 %>% filter(YEAR %in% c(2017, 2018, 2019))) # no. of rows in data from 2017-2019
