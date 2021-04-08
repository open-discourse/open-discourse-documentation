library(tidyverse)
library(datamodelr)

# requires running docker image as called by r/src/docker.R

sQuery <- dm_re_query("postgres")
sQuery <-
  sub(pattern = "public",
      replacement = "open_discourse",
      x = sQuery)

dm_od <- dbGetQuery(con, sQuery)
dm_od <- as.data_model(dm_od)

graph <- dm_create_graph(dm_od,
                         rankdir = "LR",
                         columnArrows = TRUE)

#create subfolder if needed
ifelse(!dir.exists(paste0("docs/", current_version_tag, "/images")), 
       dir.create(paste0("docs/", current_version_tag, "/images")), FALSE)

dm_export_graph(graph,
                file_name = paste0("docs/", current_version_tag, "/images/db_schema.png"))
