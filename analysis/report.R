library(tidyverse)
library(here)
library(ggplot2)
library(dplyr)


########
#pancreatic cancer rates 
########

measure_paca <- read_csv(here::here("output","measures",
                                    "measure_pa_ca_diagnosis_rate.csv"))
measure_paca$date <- as.Date(measure_paca$date,format = "%Y-%m-%d") 

paca_rate <- ggplot(data = measure_paca,
                    aes(date, value)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+#%B
  xlab("Time")+
  ylab("Pa Ca diagn (rate)")+
  labs(colour = "Station")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  plot= paca_rate, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_rate.png", path=here::here("output"),
)

write.table(measure_paca, here::here("output", "paca_rate.csv"),
            col.names= c("count", "population", "rate", "date"),sep = ",",row.names = F)

########
#pancreatic cancer rates ***by region***
########

measure_paca_region <- read_csv(here::here("output","measures",
                                           "measure_pa_ca_by_region_rate.csv"))
measure_paca_region$date <- as.Date(measure_paca_region$date,format = "%Y-%m-%d") 

cl_id <- unique(measure_paca_region$region)

paca_rate_region <- ggplot(data = measure_paca_region,
                           aes(date, value)) +
  geom_line(aes(color = region))+
  geom_point(aes(color = region))+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+#%B
  xlab("Time")+
  ylab("Pa Ca diagnosis by region (rate)")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  plot= paca_rate_region, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_rate_region.png", path=here::here("output"),
)

write.table(measure_paca_region, here::here("output", "paca_rate_region.csv"),
            col.names= c("region","count", "population", "rate", "date"),sep = ",",row.names = F)


########
#pancreatic cancer rates ***by IMD***
########

measure_paca_IMD <- read_csv(here::here("output","measures",
                                           "measure_pa_ca_by_IMD_rate.csv"))
measure_paca_IMD$date <- as.Date(measure_paca_IMD$date,format = "%Y-%m-%d") 

measure_paca_IMD$imd_cat <- as.character(measure_paca_IMD$imd_cat)

paca_rate_IMD <- ggplot(data = measure_paca_IMD,
                           aes(date, value)) +
  geom_line(aes(color = imd_cat))+
  geom_point(aes(color = imd_cat))+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+#%B
  xlab("Time")+
  ylab("Pa Ca diagnosis by IMD (rate)")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  plot= paca_rate_IMD, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_rate_IMD.png", path=here::here("output"),
)

write.table(measure_paca_IMD, here::here("output", "paca_rate_IMD.csv"),
            col.names= c("imd_cat","count", "population", "rate", "date"),sep = ",",row.names = F)

