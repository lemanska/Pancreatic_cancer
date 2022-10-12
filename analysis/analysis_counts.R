### INFO
# project: Project #27: The effect of COVID-19 on pancreatic cancer diagnosis and care.
# author: Agz Leman
# 7 September 2022
# Calculates monthly counts in the pa ca study 
# Generates output table 
###

## library
library(tidyverse)
library(here)
library(plyr)

## Redactor code (W.Hulme)
redactor <- function(n, threshold=7,e_overwrite=NA_integer_){
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

X <- read_csv(here::here("output", "input.csv"))
X$pa_ca_date <- as.Date(X$pa_ca_date,format = "%Y-%m-%d") 
X <- X[which(X$pa_ca_date>="2015-01-01" & X$pa_ca_date<="2022-09-01"),]
X$Month <- as.Date(cut(X$pa_ca_date, breaks = "month"))
X$bmi_before[X$bmi_before!=0] <- 1
X$bmi_after[X$bmi_after!=0] <- 1
# monthly counts 
monthly_count <- aggregate(. ~ Month, X[,c("Month",
                          "pa_ca", "diabetes", 
                          "bmi_before", "bmi_after", "hba1c_before", "hba1c_after",
                          "liver_funct_before","liver_funct_after", 
                          "pancreatic_imaging", "jaundice",
                          "enzyme_replace", "pancreatic_resection", 
                          "admitted_before", "admitted_after", 
                          "emergency_care_before", "emergency_care_after", 
                          "died_any", 
                          "gp_consult_before","gp_consult_after",
                          "gp_PT_consult_before","gp_PT_consult_after"
                          )], sum)
# # calculate counts of people who died each month
# t1 <- as.data.frame(table(as.Date(cut(X$died_any_date, breaks = "month")))); 
# colnames(t1) <- c("Month","died_any_month"); t1$Month <- as.Date(t1$Month)
# monthly_count <- merge(monthly_count,t1,by = "Month", all.x = TRUE); rm(t1)
# monthly_count$died_any_month[is.na(monthly_count$died_any_month)] <- 0
# 
# t1 <- as.data.frame(table(as.Date(cut(X$died_paca_date, breaks = "month")))); 
# colnames(t1) <- c("Month","died_paca_month"); t1$Month <- as.Date(t1$Month)
# monthly_count <- merge(monthly_count,t1,by = "Month", all.x = TRUE); rm(t1)
# monthly_count$died_paca_month[is.na(monthly_count$died_paca_month)] <- 0

# apply small number suppression 
monthly_count <- monthly_count %>% mutate_at(vars("pa_ca", "diabetes", 
                                                  "bmi_before", "bmi_after", "hba1c_before", "hba1c_after",
                                                  "liver_funct_before","liver_funct_after", 
                                                  "pancreatic_imaging", "jaundice",
                                                  "enzyme_replace", "pancreatic_resection", 
                                                  "admitted_before", "admitted_after", 
                                                  "emergency_care_before", "emergency_care_after", 
                                                  "died_any", 
                                                  "gp_consult_before","gp_consult_after",
                                                  "gp_PT_consult_before","gp_PT_consult_after"),redactor)

######################
# round variables with paca and all_case because if dif risk
i2 <- which(colnames(monthly_count) %in% c("pa_ca", "diabetes",
                                           "bmi_before", "bmi_after", "hba1c_before", "hba1c_after",
                                           "liver_funct_before","liver_funct_after",
                                           "pancreatic_imaging", "jaundice",
                                           "enzyme_replace", "pancreatic_resection",
                                           "admitted_before", "admitted_after",
                                           "emergency_care_before", "emergency_care_after",
                                           "died_any","gp_consult_before","gp_consult_after",
                                           "gp_PT_consult_before","gp_PT_consult_after"))
for (i in i2){
  monthly_count[,i] <- round_any(monthly_count[,i],5)
}
colnames(monthly_count)[i2] <- paste0(colnames(monthly_count[,i2]), "_ROUNED")

# summarise demographics 
######################
if (dim(X)[1]>10){
  demogs <- as.data.frame(c("tot_count", "diabetes","age","sex","ethnicity")); colnames(demogs) <- "variable"
  demogs[demogs$variable=="tot_count","popul_count"] <- dim(X)[1]
  demogs[demogs$variable=="diabetes","popul_count"] <- length(which(as.numeric(X$diabetes)==1))
  demogs[demogs$variable=="age","mean"] <- mean(X$age,na.rm = TRUE)
  demogs[demogs$variable=="age","sd"] <- sd(X$age,na.rm = TRUE)
  demogs[demogs$variable=="age","median"] <- median(X$age,na.rm = TRUE)
  demogs[demogs$variable=="age","IQR"] <- IQR(X$age,na.rm = TRUE)
  demogs[demogs$variable=="age","fstQ"] <- as.numeric(summary(X$age)[2])
  demogs[demogs$variable=="age","trdQ"] <- as.numeric(summary(X$age)[5])
  demogs[,c(names(table(X$sex)))] <- NA; demogs[demogs$variable=="sex",c(names(table(X$sex)))] <- as.numeric(table(X$sex))
  demogs[,c(names(table(X$ethnicity)))] <- NA; demogs[demogs$variable=="ethnicity",c(names(table(X$ethnicity)))] <- as.numeric(table(X$ethnicity))
  colnames(demogs)[which(colnames(demogs)=="South Asian")] <- "South_Asian"
}
###
# SAVE the output tables
###
ms <- format(ISOdatetime(2000,1:12,1,0,0,0),"%b")# generate month names
monthly_count$MonthNo <- as.numeric(substr(monthly_count$Month, 6, 7))
monthly_count$Month_name <- ms[monthly_count$MonthNo]
# save the tables 
write.table(monthly_count, here::here("output", "monthly_count.csv"),
            sep = ",",row.names = F)
write.table(demogs, here::here("output", "demographics.csv"),
            sep = ",",row.names = F)



