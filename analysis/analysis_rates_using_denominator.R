### INFO
# project: Project #27: The effect of COVID-19 on pancreatic cancer diagnosis and care.
# author: Agz Leman
# 22 Feb 2022
# Plots monthly rates 
# Generates output table 
###

## library
library(tidyverse)
library(here)
## Redactor code (W.Hulme)
redactor <- function(n, threshold=6,e_overwrite=NA_integer_){
  # given a vector of frequencies, this returns a boolean vector that is TRUE if
  # a) the frequency is <= the redaction threshold and
  # b) if the sum of redacted frequencies in a) is still <= the threshold, then the
  # next largest frequency is also redacted
  n <- as.integer(n)
  leq_threshold <- dplyr::between(n, 1, threshold)
  n_sum <- sum(n)
  # redact if n is less than or equal to redaction threshold
  redact <- leq_threshold
  # also redact next smallest n if sum of redacted n is still less than or equal to threshold
  if((sum(n*leq_threshold) <= threshold) & any(leq_threshold)){
    redact[which.min(dplyr::if_else(leq_threshold, n_sum+1L, n))] = TRUE
  }
  n_redacted <- if_else(redact, e_overwrite, n)
}

###
#download and prep the data
###

Denominator <- read_csv(here::here("output", "measures", "measure_registered_rate.csv"))

X <- read_csv(here::here("output", "input.csv"))
X$pa_ca_date <- as.Date(X$pa_ca_date,format = "%Y-%m-%d") 
X <- X[which(X$pa_ca_date>="2015-01-01"),]
X$Month <- as.Date(cut(X$pa_ca_date, breaks = "month"))

###
# plot monthly rates longitudinal  
###

# monthly counts 
paca_counts <- as.data.frame(table(X$Month))
colnames(paca_counts) <- c("date", "Panc_Ca_count")
# apply small number suppression 
paca_counts <- paca_counts %>% mutate_at(vars(Panc_Ca_count),redactor) 
# prep axis 
paca_counts$date <- as.Date(as.character(paca_counts$date,format = "%Y-%m-%d"))
paca_counts$Month <- as.Date(cut(paca_counts$date, breaks = "month"))
paca_counts$Year <- as.Date(cut(paca_counts$date, breaks = "year"))
# calculate rates of pancreatic cancer per 100,000 registered patients 
paca_rates <- merge(paca_counts, Denominator[,c("registered", "date")], by = "date")
paca_rates$rate <- paca_rates$Panc_Ca_count / paca_rates$registered * 100000
# plot 2015-2022 longitudinal
paca_time_rates <- ggplot(data = paca_rates,
                          aes(Month, rate, color = Year)) +
  geom_line(color = paca_rates$Year )+
  geom_point(color = paca_rates$Year )+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "Incident pancreatic cancer: rates per 100,000 patients", 
       x = "Time", y = "Pancreatic cancer rates")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= paca_time_rates, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_rates.png", path=here::here("output"),
)

###
#plot rates by year
###

# prep axis
paca_rates$date <- as.character(paca_rates$date)
paca_rates$Month <- as.numeric(substr(paca_rates$date, 6, 7))
paca_rates$Year <- substr(paca_rates$date, 1, 4)
# plot
paca_time_rates_year <- ggplot(data = paca_rates,
                               aes(Month, Panc_Ca_count, color = Year)) +
  geom_line()+
  geom_point()+
  scale_x_continuous(name = "Time", breaks = c(1:12),
                     label = format(ISOdatetime(2000,1:12,1,0,0,0),"%b"))+
  labs(title = "Incident pancreatic cancer: rates per 100,000 patients", 
       colour = "Year", x = "Time", y = "Pancreatic cancer rates")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= paca_time_rates_year, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_rates_year.png", path=here::here("output"),
)

###
#save the output table
###
ms <- format(ISOdatetime(2000,1:12,1,0,0,0),"%b")# generate month names 
paca_rates$Month_name <- ms[paca_rates$Month]
# save the table 
write.table(paca_rates, here::here("output", "paca_rates.csv"),
            col.names= c("date","count", "month", "year", "registered", "rate", "month_name"),
            sep = ",",row.names = F)
