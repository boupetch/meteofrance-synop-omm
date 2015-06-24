#Export to Postgres
source(file="getData.R")
source(file="postgres_con.R")

table <- "fr_synop_data"

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

# Cast temperature column
dbGetQuery(con, "UPDATE fr_synop_data SET t = NULL WHERE t = 'mq';");
dbGetQuery(con, "ALTER TABLE fr_synop_data ALTER COLUMN t TYPE numeric(10,0) USING t::numeric;");

# Cast 3 hours precipitations column
dbGetQuery(con, "UPDATE fr_synop_data SET rr3 = NULL WHERE rr3 = 'mq';");
dbGetQuery(con, "ALTER TABLE fr_synop_data ALTER COLUMN rr3 TYPE numeric(10,0) USING rr3::numeric;");

table <- "fr_synop_stations"

dbWriteTable(con,table, synopStations,row.names=FALSE,overwrite=TRUE)

#Commenting https://donneespubliques.meteofrance.fr/client/document/doc_parametres_synop_168.pdf
#TODO
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.numer_sta IS 'SYNOP station number';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.date IS 'UTC date AAAAMMDDHHMISS';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.pmer IS 'Sea level pressure (Pa)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.tend IS '3 hours pressure variation (Pa)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.cod_tend IS 'Pressure trend type http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=304';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.dd IS 'Average 10 minutes wind direction (degree)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.ff IS 'Average 10 minutes wind speed (meter/second)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.t IS 'Temperature (K)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.td IS 'Dew point (K)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.u IS 'Humidity (%)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.vv IS 'Horizontal visibility (meters)';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.ww IS 'http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=438';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.w1 IS 'http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=437';");
dbGetQuery(con, "COMMENT ON COLUMN fr_synop_data.w2 IS 'http://library.wmo.int/pmb_ged/wmo_306-v1_1-2012_en.pdf#page=437';");

dbGetQuery(con, "SELECT DISTINCT(numer_sta) FROM fr_synop_data");







