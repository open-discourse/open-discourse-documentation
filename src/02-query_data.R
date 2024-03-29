library("RPostgreSQL")
library("magrittr")

# db_connection -----------------------------------------------------------
db <- "next"
host_db <- "database" #localhost when not running in docker
db_port <- "5432"
db_user <- "postgres"
db_password <- "postgres"
con <-
  dbConnect(
    RPostgres::Postgres(),
    dbname = db,
    host = host_db,
    port = db_port,
    user = db_user,
    password = db_password,
    bigint = "integer"
  )

# get data tables ---------------------------------------------------------
speeches <- dbGetQuery(con,
                       "SELECT *
                       FROM open_discourse.speeches;")

names(speeches) %<>% snakecase::to_lower_camel_case()
speeches$searchSpeechContent <- NULL #delete search index infos of full text search 

last_covered_date <- sort(speeches$date, decreasing = TRUE)[1] #generate var with latest session date

factions <- dbGetQuery(con,
                       "SELECT *
                       FROM open_discourse.factions;")
names(factions) %<>% snakecase::to_lower_camel_case()

politicians <- dbGetQuery(con,
                          "SELECT *
                       FROM open_discourse.politicians;")
names(politicians) %<>% snakecase::to_lower_camel_case()


electoral_terms <- dbGetQuery(con,
                              "SELECT *
                       FROM open_discourse.electoral_terms;")
names(electoral_terms) %<>% snakecase::to_lower_camel_case()

contributions_simplified <- dbGetQuery(con,
                                       "SELECT *
                       FROM open_discourse.contributions_simplified;")
names(contributions_simplified) %<>% snakecase::to_lower_camel_case()

contributions_extended <- dbGetQuery(con,
                                     "SELECT *
                       FROM open_discourse.contributions_extended;")
names(contributions_extended) %<>% snakecase::to_lower_camel_case()
