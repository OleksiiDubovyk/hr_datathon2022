#install.packages("auk")
library(auk)
library(lubridate)
library(sf)
library(gridExtra)
library(tidyverse)

select <- dplyr::select

ebd <- auk_ebd("ebd_Us-VA_relJul-2022.txt", 
               file_sampling = "ebd_sampling_relJul-2022.txt")

counties <- c("550", "067", "650", "700", "710",
              "810", "735", "740", "800", "830",
              "073", "093", "095", "115", "175",  "199") %>%
  sapply(., function(i) paste("US-VA-", i, sep = "")) %>%
  unname()

ebd_filters <- ebd %>% 
  auk_date(date = c("2000-01-01", "2020-12-31")) %>% 
  auk_protocol(protocol = c("Stationary", "Traveling")) %>% 
  auk_duration(duration = c(5, 60)) %>%
  auk_distance(distance = c(0, 1), distance_units = "km") %>%
  auk_county(county = counties, replace = T) %>%
  auk_complete()

f_ebd <- "hampton_roads.txt"
f_sampling <- "hampton_roads_sampling.txt"

auk_filter(ebd_filters, file = f_ebd, file_sampling = f_sampling)

hr <- read_tsv("./hampton_roads.txt")

hr_clean <- hr %>%
  filter(CATEGORY == "species") %>%
  select(`SAMPLING EVENT IDENTIFIER`,
         `COMMON NAME`,
         `SCIENTIFIC NAME`,
         `OBSERVATION COUNT`,
         `COUNTY`,
         `LOCALITY ID`,
         LATITUDE, LONGITUDE,
         `OBSERVATION DATE`,
         `TIME OBSERVATIONS STARTED`,
         `PROTOCOL TYPE`,
         `DURATION MINUTES`,
         `EFFORT DISTANCE KM`)
colnames(hr_clean) <- c("sampling_id", "species_eng", "species_sci", "count", "county", "locality", "lat", "long", "date", "time",
                        "protocol", "duration", "distance")
hr_clean <- mutate(hr_clean, count = as.numeric(ifelse(count == "X", 1, count)))

write_csv(hr_clean, "hr_clean.csv")

# sad <- hr_clean %>%
#   group_by(species_eng) %>%
#   summarise(n = n(), a = sum(count)) %>%
#   arrange(desc(n))
# 
# plot(sort(sad$n, decreasing = T), log = "y")
# plot(sort(sad$a, decreasing = T), log = "y")
