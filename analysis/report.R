library(tidyverse)
library(here)
library(ggplot2)
library(dplyr)

fs::dir_create(here::here("output", "measures"))

#test figure of age 
df_input <- read.delim(here("output", "input_main.csv"), header=TRUE, sep=",")
plot_age <- ggplot(data=df_input, aes(age)) + geom_histogram()
ggsave(plot= plot_age,
  filename="age_plot1.png", path=here::here("output"))

#fig of paca diagnosis over time 
df_input$ca_date <- as.Date(df_input$ca_date,format = "%Y-%m-%d") 
df_input$Month <- as.Date(cut(df_input$ca_date, breaks = "month"))

paca_time <- ggplot(data = df_input,
                    aes(Month, pa_ca)) +
  stat_summary(fun = sum, geom = "line") + # or "bar"
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+# or %B
  xlab("Time")+
  ylab("Pa Ca diagn (count)")+
  labs(colour = "Station")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  plot= paca_time, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_no.png", path=here::here("output"))

#####generate a table of counts per month 
paca_counts_pm <- table(df_input$Month)
write.table(paca_counts_pm, here::here("output", "paca_counts_pm.csv"),
          col.names= c("date","count"),sep = ",",row.names = F)

##########################################################################
### this does not work ####
##########################################################################

#measure_paca <- read.delim(here("output", "measures",
#                                "measure_pa_ca_diagnosis.csv"), 
#                           header=TRUE, sep=",")

#measure_paca <- read.csv(here::here("output","measures",
#                                    "measure_pa_ca_diagnosis.csv"),
#                        header=TRUE, sep=",")

#measure_paca <- read_csv(here::here("output","measures",
#                                    "measure_pa_ca_diagnosis.csv"))

#measure_paca$date <- as.Date(measure_paca$date,format = "%Y-%m-%d") 
#measure_paca <- measure_paca %>% distinct(date, .keep_all = TRUE)

#paca_rate <- ggplot(data = measure_paca,
#                    aes(date, value)) +
#  geom_line()+
#  geom_point()+
#  #stat_summary(fun = sum, geom = "line") + # or "bar"
#  scale_x_date(date_breaks = "2 month",
#               date_labels = "%Y-%m")+#%B
#  xlab("Time")+
#  ylab("Pa Ca diagn (rate)")+
#  labs(colour = "Station")+
#  theme_bw()+
#  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#ggsave(
#  plot= paca_rate, dpi=800,width = 20,height = 10, units = "cm",
#  filename="paca_rate.png", path=here::here("output"),
#)



