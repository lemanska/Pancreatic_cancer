
library('tidyverse')

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
#download and process the main datafile
###
X <- read_csv(here::here("output", "input.csv"))
X$pa_ca_date <- as.Date(X$pa_ca_date,format = "%Y-%m-%d") 
X <- X[which(X$pa_ca_date>="2015-01-01"),]
X$Month <- as.Date(cut(X$pa_ca_date, breaks = "month"))

###
#plot 1, summary counts of pa_ca
###

paca_time210222 <- ggplot(data = X,
                          aes(Month, pa_ca)) +
  stat_summary(fun.y = sum, geom = "line") 

ggsave(
  plot= paca_time210222, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time210222.png", path=here::here("output"),
)

###
#generating counts using the summary table 
###
paca_counts <- as.data.frame(table(X$Month))#create the table of pa_ca counts by month
colnames(paca_counts) <- c("date", "Panc_Ca_count")

#apply small number suppresion 
paca_counts <- paca_counts %>% mutate_at(vars(Panc_Ca_count),redactor) 

paca_counts$date <- as.Date(as.character(paca_counts$date,format = "%Y-%m-%d"))
paca_counts$Month <- as.Date(cut(paca_counts$date, breaks = "month"))
paca_counts$Year <- as.Date(cut(paca_counts$date, breaks = "year"))

write.table(paca_counts, here::here("output", "paca_counts.csv"),
            col.names= c("date","count", "month", "year"),sep = ",",row.names = F)

paca_time_table <- ggplot(data = paca_counts,
                    aes(Month, Panc_Ca_count, color = Year)) +
  geom_line(color = paca_counts$Year )+
  geom_point(color = paca_counts$Year )+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%Y-%m")+#%B
  xlab("Time")+
  ylab("Pa Ca diagn (count)")+
  labs(colour = "Station")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  plot= paca_time_table, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_table.png", path=here::here("output"),
)


###
#plot by year
###
paca_counts <- as.data.frame(table(X$Month))
colnames(paca_counts) <- c("date", "Panc_Ca_count")
#apply small number suppression 
paca_counts <- paca_counts %>% mutate_at(vars(Panc_Ca_count),redactor) 
paca_counts$date <- as.character(paca_counts$date)
paca_counts$Month <- as.numeric(substr(paca_counts$date, 6, 7))
paca_counts$Year <- substr(paca_counts$date, 1, 4)

paca_time_table_year <- ggplot(data = paca_counts,
                               aes(Month, Panc_Ca_count, color = Year)) +
  geom_line()+
  geom_point()+
  scale_x_continuous(name = "Time", breaks = c(1:12),
                     label = format(ISOdatetime(2000,1:12,1,0,0,0),"%b"))+
  ylab("Pa Ca diagn (count)")+
  labs(colour = "Station")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  plot= paca_time_table_year, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time_table_year.png", path=here::here("output"),
)


