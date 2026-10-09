# QUESTION 3.1
# Web scraping and extraction of SAnews article

library(rvest)
library(dplyr)
library(stringr)


url <- "https://www.sanews.gov.za/south-africa/universities-challenged-prepare-graduates-ai-driven-future"


page <- read_html(url)


title <- page %>%
  html_element("title") %>%
  html_text2()


content <- page %>%
  html_elements("p") %>%
  html_text2()


content <- content[content != ""]

# Create an R data frame
web_data <- data.frame(
  title = title,
  content = paste(content, collapse = " "),
  stringsAsFactors = FALSE
)

# Display the data
web_data

# Check the amount of extracted text
nchar(web_data$content)

# QUESTION 3.2
# Text Preprocessing

library(tidytext)
library(dplyr)
library(stringr)

text <- web_data$content

text <- tolower(text)

text <- str_replace_all(text, "https?://\\S+|www\\.\\S+", "")

text <- str_replace_all(text, "[[:punct:]]", " ")

text <- str_replace_all(text, "[0-9]+", " ")

text <- str_squish(text)

words <- data.frame(text = text) %>%
  unnest_tokens(word, text)

words <- words %>%
  anti_join(stop_words, by = "word")

words

head(words, 20)

nrow(words)

# QUESTION 3.3
# Text Summarisation and Visualisation

library(ggplot2)
library(wordcloud)
library(RColorBrewer)

# Remove irrelevant website information
words <- words %>%
  filter(!word %in% c(
    "sanews", "gov", "za", "gcis", "enquiries",
    "newsfiles", "tel", "editor", "roze", "britz",
    "chief", "zanele", "mngadi", "zanelemngadi"
  ))


word_frequency <- words %>%
  count(word, sort = TRUE)

head(word_frequency, 10)


top_words <- word_frequency %>%
  slice_head(n = 10)

top_words

# Visualisation 1: Top 10 Words Bar Chart

ggplot(top_words,
       aes(x = reorder(word, n), y = n)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 Most Frequent Words in the SAnews Article",
    x = "Words",
    y = "Frequency"
  ) +
  theme_minimal()

# Visualisation 2: Word Cloud

wordcloud(
  words = word_frequency$word,
  freq = word_frequency$n,
  min.freq = 2,
  max.words = 30,
  random.order = FALSE,
  colors = brewer.pal(8, "Dark2"),
  scale = c(3, 0.7)
)

# Extractive Text Summarisation

article_paragraphs <- web_data$content %>%
  str_split("(?<=\\.)\\s+") %>%
  unlist()

article_paragraphs <- article_paragraphs[
  str_length(str_squish(article_paragraphs)) > 50
]

article_paragraphs <- article_paragraphs[
  !str_detect(
    tolower(article_paragraphs),
    "sanews|gcis|enquiries|newsfiles|editor|zanelemngadi|roze@gcis"
  )
]

paragraph_scores <- data.frame(
  paragraph = article_paragraphs,
  score = sapply(article_paragraphs, function(p) {
    paragraph_words <- tolower(str_extract_all(p, "[a-z]+")[[1]])
    
    sum(
      word_frequency$n[
        match(paragraph_words, word_frequency$word)
      ],
      na.rm = TRUE
    )
  })
)

top_paragraphs <- paragraph_scores %>%
  arrange(desc(score)) %>%
  distinct(paragraph, .keep_all = TRUE) %>%
  slice_head(n = 3)

top_paragraphs
