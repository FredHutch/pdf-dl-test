FROM fredhutch/r-shiny-base:4.3.1

RUN echo temp2
RUN apt-get --allow-releaseinfo-change update -y

RUN apt-get install -y curl libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype-dev libtiff5-dev libsodium-dev pandoc texlive-latex-base texlive-latex-extra lmodern
RUN texhash

RUN R -e "install.packages(c('lubridate', 'shiny', 'rmarkdown', 'callr'), repos='https://cran.rstudio.com/')"

ADD ./ /app

WORKDIR /app

# make sure all packages are installed
# because R does not fail when there's an error installing a package.
RUN R -f check.R --args lubridate shiny rmarkdown callr

EXPOSE 3838

CMD R -f app.R
