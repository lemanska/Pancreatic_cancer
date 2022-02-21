
library('tidyverse')

X <- read_csv(
  here::here("output", "input.csv"))

X$pa_ca_date <- as.Date(X$pa_ca_date,format = "%Y-%m-%d") 
X <- X[which(X$ca_date>="2015-01-01"),]

X$Month <- as.Date(cut(X$pa_ca_date, breaks = "month"))

paca_time210222 <- ggplot(data = X,
                          aes(Month, pa_ca)) +
  stat_summary(fun.y = sum, geom = "line") 

ggsave(
  plot= paca_time210222, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time210222.png", path=here::here("output"),
)

#####using the summary table 

tab1 <- as.data.frame(table(X$Month))
colnames(tab1) <- c("date", "Panc_Ca_count")
tab1$date <- as.Date(as.character(tab1$date,format = "%Y-%m-%d"))
tab1$Month <- as.Date(cut(tab1$date, breaks = "month"))
tab1$Year <- as.Date(cut(tab1$date, breaks = "year"))

paca_time_table <- ggplot(data = tab1,
                    aes(Month, Panc_Ca_count, color = Year)) +
  geom_line(color = tab1$Year )+
  geom_point(color = tab1$Year )+
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




