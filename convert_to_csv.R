library(foreign)
library(dplyr)

files <- system("ls data/*.sav", intern = TRUE)

get_variables_names <- function(file){
    d <- read.spss(file, use.value.labels = TRUE, to.data.frame = TRUE, 
                   reencode = "WINDOWS-1250")
    df <- data.frame(code = toupper(colnames(d)), 
               question = attributes(d)$variable.labels, 
               stringsAsFactors = FALSE)
    df
}

questions <- purrr::map_df(files, get_variables_names)
qs <- unique(questions)
qs %>% group_by(code) %>%
    filter(row_number() == 1) -> question_1

system("mkdir output")
write.csv(question_1, file = "output/questions.csv", 
          row.names = FALSE)

convert_to_df <- function(file){
    d <- read.spss(file, use.value.labels = TRUE, to.data.frame = TRUE, 
                   reencode = "WINDOWS-1250")
    
    colnames(d) <- toupper(colnames(d))
    d$ZNAM <- as.numeric(d$ZNAM)
    if("OCT" %in% colnames(d)){
        d$OCT <- as.numeric(d$OCT)    
    }
    
    d
}

surveys <- purrr::map_df(files, convert_to_df)
write.csv(surveys, file = "output/surveys.csv", 
          row.names = FALSE)


    

