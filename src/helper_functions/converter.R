library(tidyverse)
library(reticulate)
library(lubridate)

convert <- function(data, output){
  name  <- deparse(substitute(data))
  if(name == "politicians"){
    data <- data %>% 
      mutate_if(is.Date, ~as.character(.))
  }
  py_save_object(object = data,
                 filename = paste0(output, name, ".pkl"))
  write_csv(x = data, 
            file = paste0(output, name, ".csv"))
  saveRDS(object = data,
          file = paste0(output, name, ".RDS"))
  arrow::write_feather(x = data,
                       sink = paste0(output, name, ".feather"))
  
}
