library(lubridate)
library(tidyverse)

preimp <- c("CATEGORY","COMMON.NAME","OBSERVATION.COUNT",
            "LOCALITY.ID","LOCALITY.TYPE","REVIEWED","APPROVED","STATE","COUNTY","LAST.EDITED.DATE",
            "LATITUDE","LONGITUDE","OBSERVATION.DATE","TIME.OBSERVATIONS.STARTED","OBSERVER.ID",
            "PROTOCOL.TYPE","DURATION.MINUTES","EFFORT.DISTANCE.KM","LOCALITY","BREEDING.CODE",
            "NUMBER.OBSERVERS","ALL.SPECIES.REPORTED","GROUP.IDENTIFIER","SAMPLING.EVENT.IDENTIFIER",
            "TRIP.COMMENTS","HAS.MEDIA")


rawpath <- "EBD/ebd_IN_relOct-2021.txt"
nms <- names(read.delim(rawpath, nrows = 1, sep = "\t", header = T, quote = "", stringsAsFactors = F,
                        na.strings = c(""," ", NA)))
nms[!(nms %in% preimp)] <- "NULL"
nms[nms %in% preimp] <- NA
data <- read.delim(rawpath, colClasses = nms, sep = "\t", header = T, quote = "",
                   stringsAsFactors = F, na.strings = c(""," ",NA)) # 7 mins


### sensitive species
senspath <- "EBD/ebd_sensitive_relMay-2021_IN.txt"
nms1 <- names(read.delim(senspath, nrows = 1, sep = "\t", header = T, quote = "", 
                         stringsAsFactors = F, na.strings = c(""," ", NA)))
nms1[!(nms1 %in% preimp)] <- "NULL"
nms1[nms1 %in% preimp] <- NA
senssp <- read.delim(senspath, colClasses = nms1, sep = "\t", header = T, quote = "",
                     stringsAsFactors = F, na.strings = c(""," ",NA))


data <- rbind(data, senssp) # <1min



met_week <- function(dates) {
  require(lubridate)
  normal_year <- c((0:363 %/% 7 + 1), 52)
  leap_year   <- c(normal_year[1:59], 9, normal_year[60:365])
  year_day    <- yday(dates)
  return(ifelse(leap_year(dates), leap_year[year_day], normal_year[year_day])) 
}



### adding useful columns (4 mins)
data <- data %>% 
  mutate(GROUP.ID = ifelse(is.na(GROUP.IDENTIFIER),SAMPLING.EVENT.IDENTIFIER, 
                           GROUP.IDENTIFIER)) %>%
  mutate(OBSERVATION.DATE = as.Date(OBSERVATION.DATE),
         YEAR = year(OBSERVATION.DATE),
         MONTH = month(OBSERVATION.DATE),
         DAYM = day(OBSERVATION.DATE),
         DAYY = yday(OBSERVATION.DATE),
         WEEKY = met_week(OBSERVATION.DATE),
         SYEAR = if_else(DAYY <= 151, YEAR-1, YEAR), # SY = 1st June to 31st May
         WEEKSY = if_else(WEEKY > 21, WEEKY-21, 52-(21-WEEKY)))

rm(list=setdiff(ls(envir = .GlobalEnv), c("data")), pos = ".GlobalEnv")
rm(.Random.seed)
save.image("EBD/ebd_IN_relOct-2021.RData") # 7 mins


### Month of September for monthly challenge
data <- data %>% filter(YEAR == 2021 & MONTH == 10)
save.image("EBD/ebd_IN_relOct-2021_OCT.RData")

