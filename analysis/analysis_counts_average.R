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
X <- X[which(X$pa_ca_date>="2015-01-01" & X$pa_ca_date<"2022-03-01"),]
X$Month <- as.Date(cut(X$pa_ca_date, breaks = "month"))
# monthly counts 
monthly_count <- aggregate(. ~ Month, X[,c("Month",
                          "pa_ca", "diabetes", "liver_funct", "ca19_9", "CEAntigen", 
                          "pancreatic_imaging", "jaundice", "gp_ca_referral", 
                          "enzyme_replace", "pancreatic_resection", "died_any", "died_paca",
                          "admitted_before", "admitted_after", "admitted_w_ca_before", 
                          "admitted_w_ca_after", "emergency_care_before", 
                          "emergency_care_after", "gp_consult_count"
                          )], sum)
# apply small number suppression 
monthly_count <- monthly_count %>% mutate_at(vars("pa_ca", "diabetes", "liver_funct", "ca19_9", "CEAntigen", 
                                                  "pancreatic_imaging", "jaundice", "gp_ca_referral", 
                                                  "enzyme_replace", "pancreatic_resection", "died_any", "died_paca",
                                                  "admitted_before", "admitted_after", "admitted_w_ca_before", 
                                                  "admitted_w_ca_after", "emergency_care_before", 
                                                  "emergency_care_after", "gp_consult_count"),
                                             redactor)
# Merge it with the denominator table to create the monthly registered variable for calcualting rates
monthly_count <- merge(monthly_count, Denominator[,c("registered", "date")],
                       by.x = "Month", by.y = "date")


# Summarize monthly stats using median 
monthly_median <- aggregate(. ~ Month, X[,c("Month",
                                           "admitted_before", "admitted_after", 
                                           "admitted_w_ca_before", "admitted_w_ca_after", 
                                           "emergency_care_before", "emergency_care_after",
                                           "gp_consult_count"
                                           )], median)
# apply small number suppression based on number of pancreatic ca patients 
monthly_median[which(is.na(monthly_count$pa_ca)),c("admitted_before", "admitted_after", 
                  "admitted_w_ca_before", "admitted_w_ca_after", 
                  "emergency_care_before", "emergency_care_after",
                  "gp_consult_count")] <- NA

# Summarize the variables using average
# replace 0s with NAs
for (i in which(colnames(X)%in%c("age", "bmi_before", "bmi_after",
                     "hba1c_before", "hba1c_after"))){
  X[which(X[,i]==0),i] <- NA
}

monthly_average <- aggregate(. ~ Month, X[,c("Month",
                                            "age", "bmi_before", "bmi_after", 
                                            "hba1c_before", "hba1c_after" 
                                            )], mean, na.rm=TRUE, na.action=NULL)
# apply small number suppression based on number of pancreatic ca patients 
monthly_average[which(is.na(monthly_count$pa_ca)),c("age", "bmi_before", "bmi_after",
                                                    "hba1c_before", "hba1c_after")] <- NA

#############
### generate PLOTS 4 examples 
#############

###
# plot monthly rates longitudinal  
###
# calculate rates of pancreatic cancer per 100,000 registered patients 
monthly_count$rate <- monthly_count$pa_ca / monthly_count$registered * 100000
# prep axis 
monthly_count$Year <- as.Date(cut(monthly_count$Month, breaks = "year"))
# plot 2015-2022 longitudinal
paca_time_rates <- ggplot(data = monthly_count,
                          aes(Month, rate, color = Year)) +
  geom_line(color = monthly_count$Year )+
  geom_point(color = monthly_count$Year )+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "Incident pancreatic cancer: rates", 
       x = "Time", y = "Pancreatic cancer rates per 100,000 patients")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  geom_vline(xintercept =  as.numeric(as.Date("2020-03-26",format = "%Y-%m-%d")), 
             linetype="solid", color = "blue", size=1)+
  annotate("text", x = (as.Date("2020-03-26",format = "%Y-%m-%d")+150), 
           y = max(monthly_count$rate,na.rm = TRUE)-0.1*max(monthly_count$rate,na.rm = TRUE), 
           label = "lockdown \n start", color = "blue")
# save the plot 
ggsave(
  plot= paca_time_rates, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_rates.png", path=here::here("output"),
)

###
#plot rates by year
###
# prep axis
monthly_count$MonthNo <- as.numeric(substr(monthly_count$Month, 6, 7))
monthly_count$YearNo <- substr(monthly_count$Month, 1, 4)
# plot
paca_time_rates_year <- ggplot(data = monthly_count,
                               aes(MonthNo, pa_ca, color = YearNo)) +
  geom_line()+
  geom_point()+
  scale_x_continuous(name = "Time", breaks = c(1:12),
                     label = format(ISOdatetime(2000,1:12,1,0,0,0),"%b"))+
  labs(title = "Incident pancreatic cancer: rates", 
       colour = "Year", x = "Time", y = "Pancreatic cancer rates per 100,000 patients")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= paca_time_rates_year, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_rates_year.png", path=here::here("output"),
)

# count longitudinal 
paca_time_table <- ggplot(data = monthly_count,
                          aes(Month, pa_ca, color = Year)) +
  geom_line(color = monthly_count$Year)+
  geom_point(color = monthly_count$Year)+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+
  labs(title = "Incident pancreatic cancer: cases", 
       x = "Time", y = "Pancreatic cancer cases count")+
  labs(colour = "Station")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  geom_vline(xintercept =  as.numeric(as.Date("2020-03-26",format = "%Y-%m-%d")), 
             linetype="solid", color = "blue", size=1)+
  annotate("text", x = (as.Date("2020-03-26",format = "%Y-%m-%d")+150), 
           y = max(monthly_count$pa_ca,na.rm = TRUE)-0.1*max(monthly_count$pa_ca,na.rm = TRUE), 
           label = "lockdown \n start", color = "blue") 
# save
ggsave(
  plot= paca_time_table, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_table.png", path=here::here("output"),
)

# count by year 
paca_time_table_year <- ggplot(data = monthly_count,
                               aes(MonthNo, pa_ca, color = YearNo)) +
  geom_line()+
  geom_point()+
  scale_x_continuous(name = "Time", breaks = c(1:12),
                     label = format(ISOdatetime(2000,1:12,1,0,0,0),"%b"))+
  labs(title = "Incident pancreatic cancer: cases", 
       colour = "Year", y = "Pancreatic cancer cases count")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# save
ggsave(
  plot= paca_time_table_year, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_table_year.png", path=here::here("output"),
)


###
# SAVE the output tables
###
ms <- format(ISOdatetime(2000,1:12,1,0,0,0),"%b")# generate month names 
monthly_count$Month_name <- ms[monthly_count$MonthNo]
# save the table 
write.table(monthly_count, here::here("output", "monthly_count.csv"),
            sep = ",",row.names = F)
write.table(monthly_median, here::here("output", "monthly_median.csv"),
            sep = ",",row.names = F)
write.table(monthly_average, here::here("output", "monthly_average.csv"),
            sep = ",",row.names = F)



