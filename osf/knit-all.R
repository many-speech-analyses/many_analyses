files <- list.files("./osf/comps", pattern = "[.]Rmd$", recursive = T, full.names = T)
for (f in files) rmarkdown::render(f, knit_root_dir = here::here(), output_format = "github_document", envir = new.env())

