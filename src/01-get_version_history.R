library(httr)
library(dataverse)
library(dplyr)


# github ------------------------------------------------------------------
github_api <- function(path) {
  url <- modify_url("https://api.github.com", path = path)
  resp <- GET(url)
  jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
}

resp <- github_api("/repos/open-discourse/open-discourse/releases")


gh_version_history <- tibble::tibble()
for(i in 1:length(resp)){
  v <- try(resp[[i]]$tag_name)
  t <- try(resp[[i]]$published_at)
  gh_version_history <- rbind(gh_version_history, tibble::tibble(v = v, t = t))
}

gh_version_history <- gh_version_history %>% 
  mutate(t = stringr::str_extract(t, pattern = "^[^T]*"),
         t = as.Date(t)) %>% 
  arrange(desc(t))

current_version_tag <- gh_version_history[[1]][[1]]
current_version_date <- gh_version_history[[2]][[1]]

#create target folder if not available
ifelse(!dir.exists(paste0("docs/", current_version_tag)), 
       dir.create(paste0("docs/", current_version_tag)), FALSE)


# hdv ---------------------------------------------------------------------
server <- "dataverse.harvard.edu"
doi <- "doi:10.7910/DVN/FIKIBO"

od_versions <- dataset_versions(dataset = doi, 
                                server = server, 
                                key = Sys.getenv("HARVARD_DATAVERSE"))

hdv_version_history <- tibble::tibble()
for(i in 1:length(od_versions)){
  v <- try(od_versions[[i]]$versionNumber)
  t <- try(od_versions[[i]]$releaseTime)
  hdv_version_history <- rbind(hdv_version_history, tibble::tibble(v = v, t = t))
}

hdv_version_history <- hdv_version_history %>% 
  mutate(t = stringr::str_extract(t, pattern = "^[^T]*"),
         t = as.Date(t)) %>% 
  arrange(desc(t))




