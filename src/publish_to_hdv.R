library(dataverse)
source("./src/helper_functions/converter.R")
source("./src/helper_functions/update_hvd_dataset.R")

# convert and save database tables in 4 target formats --------------------
output <-  "./src/.temp/hdv_files/"

convert(speeches, output)
convert(politicians, output)
convert(factions, output)
convert(electoral_terms, output)
convert(contributions_simplified, output)
convert(contributions_extended, output)


# retrieve dataverse dataset info -----------------------------------------
server <- "dataverse.harvard.edu"
doi <- "doi:10.7910/DVN/FIKIBO"
key <- "7ac02bf7-e2f8-4df2-96ef-2689b9c71e02"


dataset_versions <- dataset_versions(dataset = doi, server = server)
old_files_info <- dataset_versions[[1]][["files"]]


# md5 check up for all files. only changed files will be uploaded -------------------------------
new_files <- list.files("./src/.temp/hdv_files/")
upload_files <- tibble()

for(i in 1:length(new_files)){
  index <- which(sapply(old_files_info, function(x) sub(".csv", ".tab", new_files[i]) %in% x))
  if(length(index) > 0){
    old_file_md5 <- old_files_info[[index]]$dataFile$md5
    new_file_md5 <- tools::md5sum(paste0(output, new_files[i]))
    if(old_file_md5 != new_file_md5){
      upload_files <- rbind(upload_files, 
                            tibble(file_name = new_files[i]))
    } else{
      print(paste("file", new_files[i], "didn't change since last update. So it won't be updated."))
    }
  } else {
    print(paste("file", new_files[i], "not present in dataverse. So it can not be updated"))
  }
}


 # update files
 for (i in 1:nrow(upload_files)) {
   print(paste("updating file", i, "name:", upload_files[i,1]))
   dv_file <- old_files_info[sapply(old_files_info, function(x) sub(".csv", ".tab", upload_files[i,1]) %in% x)]
   
   update_hvd_dataverse(
     file = paste0(output, upload_files[i,1]),
     dataset = doi,
     server = server,
     directoryLabel = str_extract(pattern = "[^.]*$", upload_files[i,1]),
     key = key,
     id = flatten(dv_file)$dataFile$id
   )
   if(str_detect(upload_files[i,1], pattern = ".csv")){
     print(paste(Sys.time(), "==== pausing 6 min because of csv processing of harvard dataverse"))
     Sys.sleep(400)
   }
   
 }
   
   
#publish new dataset
print("Publishing new dataverse version..")
publish_dataset(dataset = doi,
                 minor = FALSE,
                 key = key,
                 server = server)


