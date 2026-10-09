
# QUESTION 4.1: EXTRACT JOB ADVERTISEMENTS

packages <- c("httr", "xml2", "dplyr", "stringr", "readr")

for (p in packages) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
}

library(httr)
library(xml2)
library(dplyr)
library(stringr)
library(readr)

feed_url <- "https://weworkremotely.com/remote-jobs.rss"

response <- GET(
  feed_url,
  user_agent("Student ETL coursework")
)

stop_for_status(response)

feed <- read_xml(
  content(response, as = "text", encoding = "UTF-8")
)

items <- xml_find_all(feed, ".//item")

get_field <- function(item, field) {
  node <- xml_find_first(item, paste0("./", field))
  
  if (inherits(node, "xml_missing")) {
    return(NA_character_)
  }
  
  xml_text(node, trim = TRUE)
}

jobs <- data.frame(
  job_title = vapply(items, get_field, character(1),
                     field = "title"),
  job_description = vapply(items, get_field, character(1),
                           field = "description"),
  company_and_category = vapply(
    items, get_field, character(1), field = "category"
  ),
  job_url = vapply(items, get_field, character(1),
                   field = "link"),
  publication_date = vapply(items, get_field, character(1),
                            field = "pubDate"),
  stringsAsFactors = FALSE
)

jobs <- jobs %>%
  distinct(job_url, .keep_all = TRUE) %>%
  filter(!is.na(job_url), job_url != "") %>%
  mutate(
    word_count = str_count(
      coalesce(job_description, ""),
      boundary("word")
    )
  )

if (nrow(jobs) < 20) {
  stop("Fewer than 20 distinct jobs were collected.")
}

write_csv(jobs, "raw_jobs.csv", na = "")

print(head(jobs, 10))
print(paste("Number of job records:", nrow(jobs)))

#Question 4.2

library(dplyr)
library(stringr)
library(readr)
library(lubridate)

# Load the raw job data
jobs <- read_csv("raw_jobs.csv", show_col_types = FALSE)

# Remove HTML tags and clean job descriptions
jobs <- jobs %>%
  mutate(
    job_description = str_replace_all(
      job_description,
      "(?i)<br\\s*/?>|</p>|</div>|</li>",
      " "
    ),
    job_description = str_replace_all(
      job_description,
      "<[^>]+>",
      " "
    ),
    job_description = str_replace_all(
      job_description,
      "&nbsp;|&#160;",
      " "
    ),
    job_description = str_replace_all(
      job_description,
      "&amp;", "&"
    ),
    job_description = str_replace_all(
      job_description,
      "&quot;", "\""
    ),
    job_description = str_replace_all(
      job_description,
      "&#39;|&apos;",
      "'"
    ),
    job_description = str_squish(job_description),
    job_title = str_squish(job_title),
    company_and_category = str_squish(company_and_category)
  )

# Remove duplicate advertisements and records without titles or URLs
jobs <- jobs %>%
  distinct(job_url, .keep_all = TRUE) %>%
  filter(
    !is.na(job_title),
    job_title != "",
    !is.na(job_url),
    job_url != ""
  )

# Handle missing descriptions
jobs <- jobs %>%
  mutate(
    job_description = if_else(
      is.na(job_description) | job_description == "",
      "Description unavailable",
      job_description
    )
  )

# Convert publication dates into a consistent date format
jobs <- jobs %>%
  mutate(
    publication_date = as.Date(
      parse_date_time(
        publication_date,
        orders = "a, d b Y H:M:S z",
        tz = "UTC"
      )
    )
  )

# Recalculate word counts after cleaning
jobs <- jobs %>%
  mutate(
    word_count = if_else(
      job_description == "Description unavailable",
      0L,
      str_count(job_description, "\\S+")
    )
  )

# Check the cleaned data
print(head(jobs))
print(summary(jobs))
print(colSums(is.na(jobs)))

# Save the cleaned dataset
write_csv(jobs, "cleaned_jobs.csv")

cat("Number of cleaned job advertisements:", nrow(jobs), "\n")
cat("Cleaned dataset saved as cleaned_jobs.csv\n")


getwd()
file.exists("cleaned_jobs.csv")



























