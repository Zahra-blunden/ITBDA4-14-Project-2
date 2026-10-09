library(tm)
library(SnowballC)
library(topicmodels)
library(tidytext)
library(dplyr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)

news_path <- "E:/ITBDA/news/sa_news"

files <- list.files(
  path = news_path,
  pattern = "\\.txt$",
  full.names = TRUE
)

news_df <- data.frame(
  file_name = basename(files),
  content = sapply(
    files,
    function(x) {
      paste(
        readLines(x, encoding = "UTF-8", warn = FALSE),
        collapse = " "
      )
    }
  ),
  stringsAsFactors = FALSE
)

news_df

# Convert content into a corpus
corpus <- Corpus(VectorSource(news_df$content))

# Convert text to lowercase
corpus <- tm_map(corpus, content_transformer(tolower))

# Remove punctuation
corpus <- tm_map(corpus, removePunctuation)

# Remove numbers
corpus <- tm_map(corpus, removeNumbers)

# Remove common English stop words
corpus <- tm_map(corpus, removeWords, stopwords("english"))

# Remove extra whitespace
corpus <- tm_map(corpus, stripWhitespace)

# Apply stemming
corpus <- tm_map(corpus, stemDocument, language = "english")

# Convert the cleaned corpus back into the data frame
news_df$cleaned_content <- sapply(corpus, as.character)

# Display the cleaned data
news_df[, c("file_name", "cleaned_content")]

