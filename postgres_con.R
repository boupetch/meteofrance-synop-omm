library(RPostgreSQL)

#Create the con object
con <- dbConnect(dbDriver("PostgreSQL")
                 , host=""
                 , user= ""
                 , password=""
                 , dbname="")

#Select schema
dbGetQuery(con, "SET search_path TO weather")