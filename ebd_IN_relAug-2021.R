require(lubridate)
require(tidyverse)
library(dtplyr)
library(data.table)

rawpath <- "ebd_IN_relAug-2021.txt"

preimp <- c("CATEGORY","COMMON.NAME","OBSERVATION.COUNT",
            "LOCALITY.ID","LOCALITY.TYPE","REVIEWED","APPROVED","STATE","COUNTY","LAST.EDITED.DATE",
            "LATITUDE","LONGITUDE","OBSERVATION.DATE","TIME.OBSERVATIONS.STARTED","OBSERVER.ID",
            "PROTOCOL.TYPE","DURATION.MINUTES","EFFORT.DISTANCE.KM","LOCALITY","BREEDING.CODE",
            "NUMBER.OBSERVERS","ALL.SPECIES.REPORTED","GROUP.IDENTIFIER","SAMPLING.EVENT.IDENTIFIER",
            "TRIP.COMMENTS")

nms <- gsub(" ",".",
            names(fread(rawpath, nrows = 1, sep = "\t", header = T, quote = "", stringsAsFactors = F,
                        na.strings = c(""," ", NA))) 
)
nms[!(nms %in% preimp)] <- "NULL"
nms[nms %in% preimp] <- NA


# took 13 min
data_DT <- fread(rawpath, colClasses = nms, sep = "\t", header = T, quote = "",
                 stringsAsFactors = F, na.strings = c(""," ",NA))
names(data_DT) <- gsub(" ",".",names(data_DT))
gc()
memory.limit(size = 20000)


# creating a dtplyr (aka lazy data.table) object on which tidy operations can be done
# but does not take up additional memory; retains speed and efficiency of data.table
data <- lazy_dt(data_DT)
data <- data %>% mutate(GROUP.ID = ifelse(is.na(GROUP.IDENTIFIER),SAMPLING.EVENT.IDENTIFIER, 
                                          GROUP.IDENTIFIER)) %>%
  mutate(OBSERVATION.DATE = as.Date(OBSERVATION.DATE),
         YEAR = year(OBSERVATION.DATE),
         MONTH = month(OBSERVATION.DATE),
         DAYM = day(OBSERVATION.DATE))
gc()

rm(list=setdiff(ls(envir = .GlobalEnv), c("data","data_DT")), pos = ".GlobalEnv")
save.image("ebd_IN_relAug-2021.RData") 

gc()


## Month of August for monthly challenge ####

data <- data %>% filter(YEAR == 2021 & MONTH == 8)
data <- collect(data)
rm("data_DT")
save.image("ebd_IN_relAug-2021_AUG.RData")
