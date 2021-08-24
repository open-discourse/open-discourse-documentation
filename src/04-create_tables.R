library(dplyr)
library(tidyr)
library(stringr)
library(readr)


#missing values helper fun
is_missing <- function(x){
  if(is.character(x)){
    x == -1 | is.na(x) | str_detect(x, "not found") | x == ""
  } else {
    x == -1 | is.na(x) | str_detect(x, "not found")
  }
}

#summary table helper fun
create_summary <- function(x, dimension = FALSE, descriptions = NULL) {
  variable <- names(x)

  class <- x %>%
    summarise_all(class) %>%
    unlist(., use.names = FALSE)

  unique <- x %>%
    summarise_all(n_distinct) %>%
    unlist(., use.names = FALSE)

  missing <- x %>%
    summarise_all(is_missing) %>%
    summarise_all(sum) %>%
    gather() %>%
    mutate(
      percentage = (value / nrow(x))*100,
      percentage = formatC(percentage, 2, format = "f"),
      percentage = paste0(percentage, "%")
    ) %>%
    select(percentage)

  if (dimension == FALSE) {
    if (is.null(descriptions)) {
      summary_table <- tibble(
        Variable = variable,
        Class = class,
        `# unique` = unique,
        `Missing Values` = missing$percentage,
        Description = ""
      )
      return(summary_table)
    } else {
      summary_table <- tibble(
        Variable = variable,
        Class = class,
        `# unique` = unique,
        `Missing Values` = missing$percentage,
        Description = ""
      ) %>%
        merge(gather(descriptions, key = "Variable", value = "Description"),
              by = "Variable",
              sort = FALSE) %>%
        mutate(Description = ifelse(is.na(Description.y),
                                    Description.x,
                                    Description.y)) %>%
        select(-c("Description.x", "Description.y"))
      return(summary_table)
    }
  } else {
    summary_table <- tibble(
      Feature = c("Number of observations", "Number of variables"),
      Total = c(nrow(x), ncol(x))
    )

    return(summary_table)
  }
}



# recurring descriptions --------------------------------------------------

politicianId_desc <- c("Foreign key of the politician. This ID can be used to link the observations with the politicians table.")
factionId_desc <- c("Foreign key of the faction. This ID can be used to link the observations with the factions table.")
speechId_desc <- c("Foreign key of the speech. This ID can be used to link the observations with the speeches table.")



# speeches -------------------------------------------------------------

# remove three variables from the speeches table in the prostgres database.
# firstName, lastName & searchSpeechContent

speeches <- speeches %>%
  select(-c(firstName, lastName))

descriptions <- tibble(
  id = "Primary Key",
  session = "Number of the parliamentary session in the respective electoral term the speech was held",
  electoralTerm = "Electoral term. This is the number of the electoral term a speech was held. It can also be used as a foreign key to link the electoral term number with the electoral term table.",
  politicianId = politicianId_desc,
  speechContent = "The raw text of the speeches held in parliament. The raw text can contain positional IDs which are a foreign key to the contributions tables. See additional remarks below for further details.",
  factionId = paste(factionId_desc, "(The high amount of missing values is caused by speeches of persons that do not speak on behalf of a specific faction (e.g. members of the presidium of the Parliament))"),
  documentUrl = "Link to original PDF document of the respective protocol.",
  positionShort = "A short identifier of the speakers position - can be one of 7 values. For more details see section below.",
  positionLong = "The long position describes the position exactly as mentioned in the original protocol.",
  date = "POSIX timestamp of the day the speech was held. This timestamp uses the Europe/Berlin time zone (CEST)."
)



#dim summary
create_summary(speeches, dimension = TRUE) %>%
  write_csv("./src/.temp/speeches_dim.csv")

#full summary
create_summary(speeches, descriptions = descriptions) %>%
  write_csv("./src/.temp/speeches_sum.csv")

# factions -------------------------------------------------------------

descriptions <- tibble(
  id = paste("Primary Key.", "The missing value count is due to the fact that one ID represents missing information about a faction (-1)"),
  abbreviation = "Abbreviation of the faction/party",
  fullName = "Full faction/party name."
)


#dim summary
create_summary(factions, dimension = TRUE) %>%
  write_csv("./src/.temp/factions_dim.csv")

#full summary
create_summary(factions, descriptions = descriptions) %>%
  write_csv("./src/.temp/factions_sum.csv")

# politicians -------------------------------------------------------------

descriptions <- tibble(
  id = paste("Primary Key.", "The missing value count is due to the fact that one ID represents missing information about a politician (-1)"),
  firstName = "First name of the politician.",
  lastName = "Last name of the politician.",
  birthPlace = "Place of birth of the politician.",
  birthCountry = "Country of birth of the politician.",
  birthDate = "Date of birth of the politician.",
  deathDate = "Date of death of the politician.",
  gender = "Gender of the politician.",
  profession = "Profession of the politician.",
  aristocracy = "Royal/noble rank of the politician.",
  academicTitle = "Academic title of the politician."
)

#dim summary
create_summary(politicians, dimension = TRUE) %>%
  write_csv("./src/.temp/pol_dim.csv")

#full summary
create_summary(politicians, descriptions = descriptions) %>%
  write_csv("./src/.temp/pol_sum.csv")

# contribs_simplified -------------------------------------------------------------

descriptions <- tibble(
  id = "Primary Key",
  speechId = speechId_desc,
  textPosition = "ID that defines the position inside the respective speech the contribution belongs to.",
  content = "Content of the contribution"
)

#dim summary
create_summary(contributions_simplified, dimension = TRUE) %>%
  write_csv("./src/.temp/contributions_simplified_dim.csv")

#full summary
create_summary(contributions_simplified, descriptions = descriptions) %>%
  write_csv("./src/.temp/contributions_simplified_sum.csv")

# contribs_extended -------------------------------------------------------------

descriptions <- tibble(
  id = "Primary Key",
  speechId = speechId_desc,
  factionId = factionId_desc,
  politicianId = politicianId_desc,
  textPosition = "Identifier",
  firstName = "First name of he politician.",
  lastName = "Last name of the politician.",
  content = "Content of the contribution.",
  type = "Type of the contribution."
)

#dim summary
create_summary(contributions_extended, dimension = TRUE) %>%
  write_csv("./src/.temp/contributions_extended_dim.csv")

#full summary
create_summary(contributions_extended, descriptions = descriptions) %>%
  write_csv("./src/.temp/contributions_extended_sum.csv")


# electoral terms -------------------------------------------------------------

descriptions <- tibble(
  id = "Primary Key",
  startDate = "First day of the electoral term",
  endDate = "Last day of the electoral term"
)

#dim summary
create_summary(electoral_terms, dimension = TRUE) %>%
  write_csv("./src/.temp/electoral_terms_dim.csv")

#full summary
create_summary(electoral_terms, descriptions = descriptions) %>%
  write_csv("./src/.temp/electoral_terms_sum.csv")
