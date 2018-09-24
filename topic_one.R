library(dplyr)
library(ggplot2)

merged_2014_2018 <- readr::read_csv("output/surveys.csv")

subset_merged <- merged_2014_2018 %>%
    select(PS_21A, PS_21B, VYZKUM) %>%
    tidyr::gather(., "question", "topic", 1:2) %>%
    mutate(topic = tolower(topic), 
           date = as.Date(paste0(as.character(VYZKUM), "01"), 
                          format = "%Y%m%d")) %>%
    select(date, topic) %>%
    mutate(migrace = case_when(grepl("migra|uprch|běženc|přistěh", topic,
                                     ignore.case = TRUE) ~ "migrace", 
                               TRUE ~ "ostatní"))

subset_merged %>%
    group_by(date, migrace) %>%
    summarise(count = n()) %>%
    mutate(share = round(count / sum(count) * 100, 2)) %>%
    filter(migrace == "migrace") -> migrace_topics

migrace_topics %>%
    ggplot(., aes(x = date, y = share)) + 
    geom_line() + 
    theme_minimal() + 
    labs(x = "",
         y = "Podíl odpovědí zmiňujících téma", 
         title = "Nejzávažnější společenské témata: migrace", 
         caption = "Data: CVVM") +
    theme_minimal() + 
    scale_y_continuous(labels = function(x){return(paste(x, "%"))})

ggsave(filename = "migrace.png", width = 10, height = 7)

subset_merged_status <- merged_2014_2018 %>%
    select(PS_21A, PS_21B, IDE_1, VYZKUM) %>%
    tidyr::gather(., "question", "topic", 1:2) %>%
    mutate(topic = tolower(topic), 
           date = as.Date(paste0(as.character(VYZKUM), "01"), 
                          format = "%Y%m%d")) %>%
    select(date, topic, IDE_1) %>%
    mutate(topic = case_when(grepl("migra|uprch|běženc|přistěh", topic, 
                                   ignore.case = TRUE) ~ "migrace", 
                             grepl("důchod|senior", topic) ~ "důchod",
                             grepl("zdraž|drahot|drahý|drahé|drahá", topic) ~ "zdražování", 
                             TRUE ~ "ostatní")) %>%
    mutate(IDE_1 = case_when(IDE_1 %in% c("NA", "NEVÍ") ~ NA_character_, 
                             TRUE ~ IDE_1)) %>%
    mutate(IDE_1 = factor(IDE_1, levels = c("velmi špatná", "spíše špatná", "ani dobrá, ani špatná", 
                                            "spíše dobrá", "velmi dobrá")))

subset_merged_status %>%
    filter(!is.na(IDE_1)) %>%
    group_by(date, topic, IDE_1) %>%
    summarise(count = n()) %>%
    group_by(date, IDE_1) %>%
    mutate(share = round(count / sum(count) * 100, 2)) -> topics_grouped

imputed_data <- expand.grid(
    date = unique(topics_grouped$date), 
    topic = unique(topics_grouped$topic), 
    IDE_1 = unique(topics_grouped$IDE_1), 
    stringsAsFactors = FALSE) %>%
    left_join(., topics_grouped, by = c("date", "topic", "IDE_1")) %>%
    mutate(share = ifelse(is.na(share), 0, share))

imputed_data %>%
    filter(topic != "ostatní") %>%
    ggplot(., aes(x = date, y = share, colour = topic)) + 
    geom_line() + 
    labs(x = "", 
         y = "Podíl odpovědí zmiňujících téma", 
         colour = "Téma") + 
    facet_grid(. ~ IDE_1) +
    theme_minimal() + 
    labs(title = "Důležitost společenských témat podle životní úrovně") + 
    scale_y_continuous(labels = function(x){return(paste(x, "%"))}) + 
    theme(legend.position = "top") + 
    labs(caption = "Data: CVVM") + 
    scale_colour_viridis_d()

ggsave(filename = "migrace_by_status.png", width = 10, height = 7)
