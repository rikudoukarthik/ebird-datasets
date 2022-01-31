memory.limit(size = 20000)
load("ebd_IN_relAug-2021.RData")

data0 <- data %>% filter(OBSERVATION.DATE == "2020-10-17") %>% collect()
datas <- data0 %>% filter(CATEGORY %in% c("species","issf"))


###### stats ###

totbdr <- length(unique(data0$OBSERVER.ID))
totobs <- length(data0$COMMON.NAME)
totlists <- length(unique(data0$SAMPLING.EVENT.IDENTIFIER))
totspecs <- length(unique(datas$COMMON.NAME))
# complete lists
clists <- data0 %>% filter(ALL.SPECIES.REPORTED == 1)
totclists <- length(unique(clists$SAMPLING.EVENT.IDENTIFIER))
# states
totstates <- length(unique(data0$STATE))
