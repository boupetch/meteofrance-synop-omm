#Meteo
#https://donneespubliques.meteofrance.fr/?fond=produit&id_produit=90&id_rubrique=32
#Documentation:https://donneespubliques.meteofrance.fr/client/document/doc_parametres_synop_168.pdf
library(RCurl)
library(lubridate)

#Stations list

filename <- "postesSynop.csv"

if(!file.exists(filename)){
  f = CFILE(filename, mode="wb")
  curlPerform(url = "https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/postesSynop.csv", writedata = f@ref)
  close(f)
}

synopStations <- read.csv2(filename)

#Weather data
meteoData <- list()

date <- as.Date("19951201",format="%Y%m%d")

while(format(date,"%Y%m") < format(Sys.Date(),"%Y%m")){
  
  month(date) <- month(date) + 1
  
  #Download file
  filename <- gsub(" ", "",paste ("synop.",format(date,"%Y%m"),".csv.gz"))
  
  if(!file.exists(filename) | (format(date,"%Y%m") == format(Sys.Date(),"%Y%m"))){
    f = CFILE(filename, mode="wb")
    curlPerform(url = gsub(" ", "",paste("https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/synop.",format(date,"%Y%m"),".csv.gz")), writedata = f@ref)
    close(f)
  }
  
  meteoData[[format(date,"%Y%m")]] <- read.csv2(gzfile(filename))
  
  print(format(date,"%Y%m"))
}

#Perform date transformations
for (name in names(meteoData)) {

  #Date characters
  meteoData[[name]]$date_string <- format(meteoData[[name]]$date, scientific = FALSE)
  meteoData[[name]]$date_string <- as.character(meteoData[[name]]$date_string)
  
  #Year
  meteoData[[name]]$year <- as.numeric(substr(meteoData[[name]]$date_string, 1, 4))
  
  #Month
  meteoData[[name]]$month <- as.numeric(substr(meteoData[[name]]$date_string, 5, 6))
  
  #Day
  meteoData[[name]]$day <- as.numeric(substr(meteoData[[name]]$date_string, 7, 8))
  
  #Hour
  meteoData[[name]]$hour <- as.numeric(substr(meteoData[[name]]$date_string, 9, 10))

}


















