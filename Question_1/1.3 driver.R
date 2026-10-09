# ==========================================
# ITBDA4-14 PROJECT 2
# MAPREDUCE DRIVER
# ==========================================

setwd("E:/ITBDA/map_reduce_test_docs")


# ==========================================
# LOAD MAPPER AND REDUCER
# ==========================================

source("mapper.R")
source("reducer.R")


# ==========================================
# SEARCH KEYWORD
# ==========================================

cat("====================================\n")
cat("MAPREDUCE KEYWORD SEARCH\n")
cat("====================================\n")

# Open an input box for the keyword
keyword <- rstudioapi::showPrompt(
  title = "MapReduce Keyword Search",
  message = "Enter the keyword to search for:"
)

if (is.null(keyword)) {
  stop("Keyword input was cancelled.")
}

keyword <- trimws(keyword)

if (keyword == "") {
  stop("No keyword was entered.")
}

cat("\nSearching for keyword:", keyword, "\n\n")


# ==========================================
# FIND THE 7 TEXT DOCUMENTS
# ==========================================

folder <- "map_reduce_test_docs"

files <- list.files(
  folder,
  pattern = "\\.txt$",
  full.names = TRUE
)

if (length(files) == 0) {
  stop("No TXT documents found.")
}

cat("Found", length(files), "documents.\n\n")


# ==========================================
# PREPARE INPUT
# ==========================================

input <- c()

for (file in files) {
  
  document <- basename(file)
  
  text <- readLines(
    file,
    warn = FALSE,
    encoding = "UTF-8"
  )
  
  for (row in seq_along(text)) {
    
    input <- c(
      input,
      paste(
        document,
        row,
        text[row],
        sep = "\t"
      )
    )
  }
}


# ==========================================
# MAPPER
# ==========================================

cat("Running Mapper...\n")

mapper_results <- mapper(
  input,
  keyword
)


# ==========================================
# REDUCER
# ==========================================

cat("Running Reducer...\n")

final_results <- reducer(
  mapper_results
)


# ==========================================
# FINAL RESULTS
# ==========================================

cat("\n")
cat("====================================\n")
cat("FINAL MAPREDUCE RESULTS\n")
cat("====================================\n\n")

if (nrow(final_results) == 0) {
  
  cat(
    "No occurrences of '",
    keyword,
    "' were found.\n",
    sep = ""
  )
  
} else {
  
  for (i in 1:nrow(final_results)) {
    
    cat(
      "Document:", final_results$Document[i],
      "| Row:", final_results$Row[i],
      "| Column:", final_results$Column[i],
      "\n"
    )
  }
}


# ==========================================
# SAVE RESULTS
# ==========================================

write.csv(
  final_results,
  "mapreduce_results.csv",
  row.names = FALSE
)

cat("\nResults saved to mapreduce_results.csv\n")

cat("\n")
print(final_results)