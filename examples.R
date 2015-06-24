source(file="postgres_con.R")

## Get the nearest station
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

## Get the average temperature in Celsius for a station and day during daytime
d2014 <- dbGetQuery(con,"SELECT year,month,day,AVG(t)-273.15 as t,
                year*10000+month*100+day as date
                FROM fr_synop_data 
                WHERE numer_sta = 7149
                AND year = 2014 
                AND hour BETWEEN 9 AND 18
                GROUP BY year,month,day
                ORDER BY day")

d2014 <- dbGetQuery(con,"SELECT numer_sta as station,month,day,AVG(t)-273.15 as t
                FROM fr_synop_data
                WHERE numer_sta = 89642
                AND year = 2014 
                AND hour BETWEEN 9 AND 18
                GROUP BY numer_sta,year,month,day
                ORDER BY day")


library("ggplot2")

#Temperatures moyennes
avgTemp2014 <- dbGetQuery(con,"SELECT s.\"Nom\" as station,month,day,AVG(t)-273.15 as Temperature
FROM fr_synop_data d
JOIN fr_synop_stations s ON d.numer_sta = s.\"ID\"
WHERE year = 2014
GROUP BY  s.\"Nom\",year,month,day")

jpeg("temp.jpg",3000,2500,res=200)
p <- ggplot(data=avgTemp2014, aes(x=month, y=reorder(day,-day), fill=temperature))
p <- p + geom_tile()
p <- p + scale_fill_gradientn(colours = rev(c('#F21A00','#E1AF00','#EBCC2A','#78B7C5','#3B9AB2','#006E89','#004B5D','#002129'))) 
p <- p + scale_x_discrete(expand = c(0,0),limits = unique(avgTemp2014$month))
p <- p + xlab("Month")
p <- p + ylab("Days")
p <- p + ggtitle("Climates in France")
p <- p + facet_wrap(~station,nrow = 10, ncol = 6)
p <- p + theme(axis.text.y = element_text(size=3),
               plot.title=element_text(family="Helvetica", face="bold", size=30))
p
dev.off()

#Précipitations et températures par mois et par an 
sumPrec2014 <- dbGetQuery(con,"SELECT AVG(precipitation) as precipitation,AVG(temperature) as temperature,month,station FROM
(SELECT s.\"Nom\" as station,month,SUM(rr3) as precipitation,year,AVG(t)-273.15 as Temperature
FROM fr_synop_data d
JOIN fr_synop_stations s ON d.numer_sta = s.\"ID\"
GROUP BY  s.\"Nom\",month,year) s
GROUP BY month,station")

jpeg("precipitations.jpg",3000,2500,res=200)
p <- ggplot(data=sumPrec2014, aes(x=month, y=precipitation))
p <- p + geom_line()
p <- p + geom_bar(data=sumPrec2014, aes(x=month, y=temperature))
p <- p + scale_x_discrete(expand = c(0,0),limits = unique(sumPrec2014$month))
p <- p + xlab("Month")
p <- p + ylab("Days")
p <- p + ggtitle("Climates in France")
p <- p + facet_wrap(~station,nrow = 11, ncol = 6
                    )
p <- p + theme(axis.text.y = element_text(size=3),
               plot.title=element_text(family="Helvetica", face="bold", size=30))
p
dev.off()
