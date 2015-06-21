source(file="getData.R")

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