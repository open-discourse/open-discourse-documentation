xfun::in_dir(dir = "src/docs/", 
             bookdown::render_book(input = ".", output_dir = paste0("../../docs/", current_version_tag, "/")))


