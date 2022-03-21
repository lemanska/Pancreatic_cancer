### INFO
# project: Project #27: The effect of COVID-19 on pancreatic cancer diagnosis and care.
# author: Agz Leman
# 22 Feb 2022
# Plots monthly counts, analysis_rates.R has been created to plot rates 
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
# download and process the main datafile
###
X <- read_csv(here::here("output", "input.csv"))
X$pa_ca_date <- as.Date(X$pa_ca_date,format = "%Y-%m-%d") 
X <- X[which(X$pa_ca_date>="2015-01-01"),]
X$Month <- as.Date(cut(X$pa_ca_date, breaks = "month"))

###
# plot 1, summary counts of pa_ca
###

paca_time <- ggplot(data = X,
                          aes(Month, pa_ca)) +
  stat_summary(fun.y = sum, geom = "line")+
    geom_vline(xintercept =  as.numeric(as.Date("2020-03-26",format = "%Y-%m-%d")), 
               linetype="solid", color = "blue", size=1.5)

ggsave(
  plot= paca_time, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time.png", path=here::here("output"),
)

###
# generate counts using the summary table 
###
paca_counts <- as.data.frame(table(X$Month))#create the table of pa_ca counts by month
colnames(paca_counts) <- c("date", "Panc_Ca_count")
# apply small number suppresion 
paca_counts <- paca_counts %>% mutate_at(vars(Panc_Ca_count),redactor) 
# prep plot axis
paca_counts$date <- as.Date(as.character(paca_counts$date,format = "%Y-%m-%d"))
paca_counts$Month <- as.Date(cut(paca_counts$date, breaks = "month"))
paca_counts$Year <- as.Date(cut(paca_counts$date, breaks = "year"))
# plot
paca_time_table <- ggplot(data = paca_counts,
                    aes(Month, Panc_Ca_count, color = Year)) +
  geom_line(color = paca_counts$Year )+
  geom_point(color = paca_counts$Year )+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "Incident pancreatic cancer: cases", 
       x = "Time", y = "Pancreatic cancer count")+
  labs(colour = "Station")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  geom_vline(xintercept =  as.numeric(as.Date("2020-03-26",format = "%Y-%m-%d")), 
             linetype="solid", color = "blue", size=1)+
  annotate("text", x = (as.Date("2020-03-26",format = "%Y-%m-%d")+150), 
           y = max(paca_counts$Panc_Ca_count,na.rm = TRUE)-0.1*max(paca_counts$Panc_Ca_count,na.rm = TRUE), 
           label = "lockdown \n start", color = "blue") 
# save
ggsave(
  plot= paca_time_table, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_table.png", path=here::here("output"),
)

###
# plot by year
###
# create summary table 
paca_counts <- as.data.frame(table(X$Month))
colnames(paca_counts) <- c("date", "Panc_Ca_count")
# apply small number suppression 
paca_counts <- paca_counts %>% mutate_at(vars(Panc_Ca_count),redactor) 
# prep axis
paca_counts$date <- as.character(paca_counts$date)
paca_counts$Month <- as.numeric(substr(paca_counts$date, 6, 7))
paca_counts$Year <- substr(paca_counts$date, 1, 4)
# plot
paca_time_table_year <- ggplot(data = paca_counts,
                               aes(Month, Panc_Ca_count, color = Year)) +
  geom_line()+
  geom_point()+
  scale_x_continuous(name = "Time", breaks = c(1:12),
                     label = format(ISOdatetime(2000,1:12,1,0,0,0),"%b"))+
  labs(title = "Incident pancreatic cancer: cases", 
       colour = "Year", y = "Pancreatic cancer count")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= paca_time_table_year, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_table_year.png", path=here::here("output"),
)

