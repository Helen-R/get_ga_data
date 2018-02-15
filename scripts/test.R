# test

require(RGoogleAnalytics)
require(RJSONIO)
source("../auxiliary/slackme.R")
library(data.table)
library(dplyr)

# # Authorize the Google Analytics account
# # This need not be executed in every session once the token object is created 
# # and saved
# x <- fromJSON("cid_bigq_helen.json")
# token <- Auth(client.id = x$installed$client_id, client.secret = x$installed$client_secret)
# 
# # Save the token object for future sessions
# save(token, file="./token_bigq_file")
# # In future sessions it can be loaded by running load("./token_file")

load("./token_bigq_file")
ValidateToken(token)

# # Build a list of all the Query Parameters
# query.list <- Init(start.date = "2013-11-28",
#                    end.date = "2013-12-04",
#                    dimensions = "ga:date,ga:pagePath,ga:hour,ga:medium",
#                    metrics = "ga:sessions,ga:pageviews",
#                    max.results = 10000,
#                    sort = "-ga:date",
#                    table.id = "ga:33093633")
# 
# # Create the Query Builder object so that the query parameters are validated
# ga.query <- QueryBuilder(query.list)
# 
# # Extract the data and store it in a data-frame
# ga.data <- GetReportData(ga.query, token, split_daywise = T, delay = 5)



# BigQuery
library(bigrquery)
project <- "hazel-phoenix-133609" # put your project ID here
dataset <- list_datasets(project)
ga <- list_tables(project, dataset[1])
ord <- list_tables(project, dataset[2])
# sql <- "SELECT year, month, day, weight_pounds FROM [publicdata:samples.natality] LIMIT 5"
# sql <- "SELECT YearMonth, MemberCount, GMV, SalesOrderDM_ShopId FROM [hazel-phoenix-133609:orders.shop_gmv_source] LIMIT 5"
d <- ord[grep("gross_transaction", ord)]
sql <- sprintf("SELECT * FROM [%s:orders.%s]", project, d2[6])
# a <- sapply(sql[1], function(s) query_exec(s, project = project, max_pages = Inf))
gmv <- query_exec(sql, project = project, max_pages = Inf)

sql <- sprintf("SELECT * FROM [%s:orders.%s]", project, d2[14])
stores <- query_exec(sql, project = project, max_pages = Inf)
slackme(msg = "bq export done")

gmv1 <- gmv[TradesOrderSource=="ALL"&MemberType=="ALL"]
save(list=c("gmv", "gmv1"), file="gmv.RData")
save(stores, file="stores.RData")

library(data.table)
library(dplyr)

load("gmv.RData")
load("stores.RData")

gmv1[, SalesOrderDM_ShopId:=sprintf("%05d", as.integer(SalesOrderDM_ShopId))]
# gmv1[, SalesOrderDM_ShopId:=as.factor(SalesOrderDM_ShopId)]
gmv1[, nth.mth:=1:.N, by=SalesOrderDM_ShopId]
gmv2 <- gmv1[,.(n.member=sum(MemberCount), mn.order=mean(OrderCount), mn.gmv=mean(GMV), 
                ttl.gmv=sum(GMV), n.mth=.N), by=SalesOrderDM_ShopId]
setorder(gmv2, SalesOrderDM_ShopId)
View(gmv2)
stores$StoreId <- sprintf("%05d",stores$StoreId)
gmv3 <- left_join(gmv2, stores, by=c("SalesOrderDM_ShopId"="StoreId"))
gmv4 <- gmv3[gmv3$ShopStatusDef=="Open",]
gmv5 <- gmv3[gmv3$ShopStatusDef=="Closed",]
