library(tidyverse)
library(dtplyr)
library(data.table)
library(lubridate)

memory.limit(size = 20000)
load("ebd_IN_relAug-2021.RData")

datax <- data %>% filter(STATE == "Delhi" | COUNTY %in% c("Faridabad","Gurgaon"))
 
datax3 <- collect(datax)

datax2 <- datax3 %>% filter(YEAR < 2021) %>% 
  filter(case_when(YEAR == 2020 ~ MONTH <= 3,
                   T ~ MONTH == MONTH))

write.csv(datax2, "ebd_IN_Mangar_relAug-2021.csv", row.names = F)
write_delim(datax2, "ebd_IN_Mangar_relAug-2021.txt")
