
library('tidyverse')

X <- read_csv(
  here::here("output", "input.csv"))

X$ca_date <- as.Date(X$ca_date,format = "%Y-%m-%d") 
X <- X[-which(X$ca_date<"2015-01-01"),]


X$Month <- as.Date(cut(X$ca_date, breaks = "month"))

tab1 <- table(X$Month)

paca_time <- ggplot(data = X,
                    aes(Month, pa_ca)) +
  stat_summary(fun = sum, geom = "line") 

ggsave(
  plot= paca_time, dpi=800,width = 20,height = 10, units = "cm",
  filename="paca_time210222.png", path=here::here("output"),
)
