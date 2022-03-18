### INFO
# project: Project #27: The effect of COVID-19 on pancreatic cancer diagnosis and care
# subproject: NICE Quality statement 4: Pancreatic enzyme replacement therapy
# author: Agz Leman
# 28 Feb 2022
# Plots monthly rates 
###

## library
library(tidyverse)
library(here)

###
#download and prep the data
###

ERx_Rates <- read_csv(here::here("output", "measures", "measure_enzymeRx_rate.csv"))

# calc rate per 1000
ERx_Rates$rate <- ERx_Rates$enzyme_replace / ERx_Rates$population * 1000
###
# plot monthly number of Rxs
###
ERx_number <- ggplot(data = ERx_Rates,
                    aes(date, enzyme_replace)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "Patients receiving enzyme replacement", 
       x = "Time", y = "Number of patients")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= ERx_number, dpi=800,width = 20,height = 10, units = "cm",
  filename="ERx_number.png", path=here::here("output"),
)

###
# plot monthly rates per 1000
###
ERx_rates <- ggplot(data = ERx_Rates,
                          aes(date, rate)) +
  geom_line()+
  geom_point()+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "Patients receiving enzyme replacement", 
       x = "Time", y = "Rate per 1000 patients diagnosed")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= ERx_rates, dpi=800,width = 20,height = 10, units = "cm",
  filename="ERx_rates.png", path=here::here("output"),
)
