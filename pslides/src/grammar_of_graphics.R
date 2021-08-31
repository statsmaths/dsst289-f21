library(tidyverse)
library(stringi)

theme_set(theme_minimal())

food <- read_csv("../../notes/data/food.csv")

p <- food %>%
  ggplot() +
    geom_point(aes(x = calories, y = total_fat))
ggsave("../imgs/scatter1.jpg", plot = p, height = 5, width = 7)

p <- food %>%
  ggplot() +
    geom_text(aes(x = calories, y = total_fat, label = item))
ggsave("../imgs/scatter2.png", plot = p, height = 5, width = 7)

p <- food %>%
  ggplot() +
    geom_segment(aes(x = calories, y = sat_fat, xend = calories, yend = total_fat))
ggsave("../imgs/scatter3.png", plot = p, height = 5, width = 7)

p <- food %>%
  ggplot() +
    geom_segment(
      aes(x = calories, y = sat_fat, xend = calories, yend = total_fat),
      arrow = arrow(length = unit(0.03, "npc"))
    )
ggsave("../imgs/scatter4.png", plot = p, height = 5, width = 7)

p <- food %>%
  ggplot() +
    geom_segment(aes(x = calories, xend = calories, yend = total_fat), y = 0)
ggsave("../imgs/scatter5.png", plot = p, height = 5, width = 7)


country_div <- tibble(
   country = c("USA", "Canada", "France", "Germany", "China"),
   division = c("state", "province", "département", "federated state", "province"),
   number = c(50, 10, 101, 16, 23)
)

p <- country_div %>%
  ggplot() +
    geom_col(aes(x = country, y = number)) +
    geom_text(aes(x = country, y = number + 3, label = division))
ggsave("../imgs/scatter6.png", plot = p, height = 5, width = 7)
