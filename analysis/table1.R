library('tidyverse')

X <- read_csv(
  here::here("output", "input_main.csv"))

X$ca_date <- as.Date(X$ca_date,format = "%Y-%m-%d") 
X$Month <- as.Date(cut(X$ca_date, breaks = "month"))

table(X$Month)

paca_time <- ggplot(data = X,
       aes(Month, pa_ca)) +
  stat_summary(fun.y = sum, geom = "line") 

ggsave(
  plot= paca_time,
  filename="paca_time.png", path=here::here("output"),
)