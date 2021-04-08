library(httr)

github_api <- function(path) {
  url <- modify_url("https://api.github.com", path = path)
  resp <- GET(url)
  jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
}

resp <- github_api("/repos/open-discourse/open-discourse/releases")

current_version_tag <- resp[[1]]$tag_name
current_version_date <- str_extract(resp[[1]][["published_at"]], pattern = "^[^T]*")


#create target folder if not available

ifelse(!dir.exists(paste0("docs/", current_version_tag)), 
       dir.create(paste0("docs/", current_version_tag)), FALSE)



