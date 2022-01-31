library('tidyverse')

df_input <- read_csv(
  here::here("output", "input_main.csv"),
  col_types = cols(patient_id = col_integer(),age = col_double())
)

plot_age <- ggplot(data=df_input, aes(df_input$age)) + geom_histogram()

ggsave(
  plot= plot_age,
  filename="age_plot1.png", path=here::here("output"),
)
