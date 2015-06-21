source(file="postgres_con.R")

get_nearest_station <- function(long,lat){
  synopStations <- dbReadTable(con,'fr_synop_stations')
  synopStations$distance <- apply(synopStations[,c('Latitude','Longitude')], 1,
                                  function(x){
                                    synopStations$distance <- earth.dist(as.numeric(x['Longitude']),as.numeric(x['Latitude']),long,lat)
                                  })
  
  synopStations[ which(synopStations$distance==min(synopStations$distance, na.rm = TRUE)), ]
}

earth.dist <- function (long1, lat1, long2, lat2) 
{
  rad <- pi/180
  a1 <- lat1 * rad
  a2 <- long1 * rad
  b1 <- lat2 * rad
  b2 <- long2 * rad
  dlon <- b2 - a2
  dlat <- b1 - a1
  a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R <- 6378.145
  d <- R * c
  return(d)
}

get_nearest_station(2.327728,48.857487)
get_nearest_station(1.081467,49.434645)

