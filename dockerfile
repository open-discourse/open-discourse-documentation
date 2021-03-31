FROM rocker/r-base:4.0.2

#install ubuntu packages
RUN \
  apt-get update -y && \
  apt-get install -y apt-utils

RUN apt-get install libpq-dev -y
RUN apt-get install libz-dev -y
RUN apt-get install libxml2-dev -y
RUN apt-get install librsvg2-dev -y
RUN apt-get install libnode-dev -y
RUN apt-get install libcurl4-openssl-dev -y

## update system libraries
RUN apt-get update

# install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/2.11.2/pandoc-2.11.2-1-amd64.deb
RUN dpkg -i pandoc-2.11.2-1-amd64.deb
RUN rm pandoc-2.11.2-1-amd64.deb

# copy necessary files
## root folder
COPY . .

# install renv & restore packages
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@0.10.0')"

RUN Rscript -e 'renv::consent(provided = TRUE)'
RUN Rscript -e 'renv::restore()'
