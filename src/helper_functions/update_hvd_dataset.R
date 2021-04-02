update_hvd_dataverse <- function (file, dataset = NULL, id, description = NULL, directoryLabel, force = TRUE, 
          key = Sys.getenv("DATAVERSE_KEY"), server = Sys.getenv("DATAVERSE_SERVER"), 
          ...) 
{
  bod2 <- list(forceReplace = force)
  if (!is.null(description)) {
    bod2$description <- description
  }
  if(!is.null(directoryLabel)) {
    bod2$directoryLabel <- directoryLabel
  }
  jsondata <- as.character(jsonlite::toJSON(bod2, auto_unbox = TRUE))
  u <- paste0(api_url(server), "files/", id, "/replace")
  r <- httr::POST(u, httr::add_headers(`X-Dataverse-key` = key), 
                  ..., body = list(file = httr::upload_file(file), jsonData = jsondata), 
                  encode = "multipart")
  httr::stop_for_status(r, task = httr::content(r)$message)
  structure(jsonlite::fromJSON(httr::content(r, as = "text", 
                                             encoding = "UTF-8"), simplifyDataFrame = FALSE)$data$files[[1L]], 
            class = "dataverse_file")
}

api_url <- function (server = server, prefix = "api/") 
{
  if (is.null(server) || server == "") {
    stop("'server' is missing with no default set in DATAVERSE_SERVER environment variable.")
  }
  server_parsed <- httr::parse_url(server)
  if (is.null(server_parsed[["hostname"]]) || server_parsed[["hostname"]] == 
      "") {
    server_parsed[["hostname"]] <- server
  }
  if (is.null(server_parsed[["port"]]) || server_parsed[["port"]] == 
      "") {
    domain <- server_parsed[["hostname"]]
  }
  else {
    domain <- paste0(server_parsed[["hostname"]], ":", server_parsed[["port"]])
  }
  return(paste0("https://", domain, "/", prefix))
}
