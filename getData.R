#Meteo
#https://donneespubliques.meteofrance.fr/?fond=produit&id_produit=90&id_rubrique=32
library(RCurl)
library(lubridate)

meteoData <- list()

date <- as.Date("19960101",format="%Y%m%d")

while(format(date,"%Y%m") <= format(Sys.Date(),"%Y%m")){
  
  #Download file
  filename <- gsub(" ", "",paste ("synop.",format(date,"%Y%m"),".csv.gz"))
  
  if(!file.exists(filename)){
    f = CFILE(filename, mode="wb")
    curlPerform(url = gsub(" ", "",paste("https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/synop.",format(date,"%Y%m"),".csv.gz")), writedata = f@ref)
    close(f)
  }
  
  meteoData[[format(date,"%Y%m")]] <- read.csv2(gzfile(filename))
  
  month(date) <- month(date) + 1
  print(format(date,"%Y%m"))
}

#Current monthly file is always re-downloaded to get latest updates
f = CFILE(filename, mode="wb")
curlPerform(url = gsub(" ", "",paste("https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/synop.",format(date,"%Y%m"),".csv.gz")), writedata = f@ref)
close(f)

#Export to CSV
exportFilename <- "meteo.csv"

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