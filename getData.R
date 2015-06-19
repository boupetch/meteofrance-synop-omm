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
  #names(meteoData[[name]])[names(meteoData[[name]])=="date"] <- "date_synop"
  
  #Date
  meteoData[[name]]$date <- format(meteoData[[name]]$date_synop, scientific = FALSE)
  #meteoData[[name]]$date <- as.character(meteoData[[name]]$date)
  #meteoData[[name]]$date <- as.Date(meteoData[[name]]$date_synop, format = "%Y%m%d%H%M%S", origin="1960-10-01")
  
  #Year
  meteoData[[name]]$year <- substr(meteoData[[name]]$date, 1, 4)
  
  #Month
  meteoData[[name]]$month <- substr(meteoData[[name]]$date, 5, 6)
  
  #Day
  meteoData[[name]]$day <- substr(meteoData[[name]]$date, 7, 8)
  
  #Hour
  meteoData[[name]]$hour <- substr(meteoData[[name]]$date, 9, 10)

}
x <- meteoData[[1]]

#Export to CSV

exportFilename <- "synop.csv"

file.remove(exportFilename)

count <- 0
for (name in names(meteoData)) {
  print(name)
  if(count == 0){
    write.table(meteoData[[name]], file = exportFilename,sep = ";",row.names = FALSE,col.names = TRUE)
  } else{
    write.table(meteoData[[name]], file = exportFilename, append=TRUE,sep = ";",row.names = FALSE,col.names = FALSE)
  }
  count <- count+1
}
#Export to Postgres
library(RPostgreSQL)

con <- dbConnect(dbDriver("PostgreSQL")
                 , host=""
                 , user= ""
                 , password=""
                 , dbname="")

dbGetQuery(con, "SET search_path TO meteo")

table <- "synop_data"

count <- 0
for (name in names(meteoData)) {
  print(name)
  if(count == 0){
    dbWriteTable(con,table, meteoData[[name]],row.names=FALSE,overwrite=TRUE)
  } else{
    dbWriteTable(con,table, meteoData[[name]],append=TRUE,overwrite=FALSE,row.names=FALSE)
  }
  count <- count+1
}

table <- "synop_stations"

dbWriteTable(con,table, synopStations,row.names=FALSE,overwrite=TRUE)

#Commenting that shit https://donneespubliques.meteofrance.fr/client/document/doc_parametres_synop_168.pdf
dbGetQuery(con, "COMMENT ON COLUMN synop.numer_sta IS 'SYNOP station number';");
dbGetQuery(con, "COMMENT ON COLUMN synop.date IS 'UTC date AAAAMMDDHHMISS';");
dbGetQuery(con, "COMMENT ON COLUMN synop.pmer IS 'Sea level pressure (Pa)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.tend IS '3 hours pressure variation (Pa)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.cod_tend IS 'Pressure trend type http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=304';");
dbGetQuery(con, "COMMENT ON COLUMN synop.dd IS 'Average 10 minutes wind direction (degree)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.ff IS 'Average 10 minutes wind speed (meter/second)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.t IS 'Temperature (K)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.td IS 'Dew point (K)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.u IS 'Humidity (%)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.vv IS 'Horizontal visibility (meters)';");
dbGetQuery(con, "COMMENT ON COLUMN synop.ww IS 'http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=438';");
dbGetQuery(con, "COMMENT ON COLUMN synop.w1 IS 'http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=437';");
dbGetQuery(con, "COMMENT ON COLUMN synop.w2 IS 'http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=437';");
dbGetQuery(con, "COMMENT ON COLUMN synop.n IS '';");
dbGetQuery(con, "COMMENT ON COLUMN synop.nbas IS '';");
dbGetQuery(con, "COMMENT ON COLUMN synop.hbas IS '';");
dbGetQuery(con, "COMMENT ON COLUMN synop.cl IS '';");
dbGetQuery(con, "COMMENT ON COLUMN synop.cm IS '';");
dbGetQuery(con, "COMMENT ON COLUMN synop.ch IS '';");
dbGetQuery(con, "COMMENT ON COLUMN synop. IS '';");

dbGetQuery(con, "SELECT DISTINCT(numer_sta) FROM synop");
















