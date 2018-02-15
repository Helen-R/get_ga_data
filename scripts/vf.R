if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib(c("RGoogleAnalytics", "RJSONIO", "data.table", "dplyr", "RODBC"))

# # [ref] http://thinktostart.com/using-google-analytics-r/

# # Authorize the Google Analytics account
# # This need not be executed in every session once the token object is created 
# # and saved
# x <- fromJSON("cid_ga1k.json")
# token <- Auth(client.id = x$installed$client_id, client.secret = x$installed$client_secret)
# 
# # Save the token object for future sessions
# save(token, file="./token_ga1k_file")
# # In future sessions it can be loaded by running load("./token_file")

load("./token_ga1k_file")
ValidateToken(token)

st.dt <- "2017-03-13"
# ed.dt <- (as.Date(st.dt) + 6) %>% as.character()
ed.dt <- "2017-03-19"

view.id <- "99772568"
# Build a list of all the Query Parameters
query.list <- Init(start.date = st.dt,
                   end.date = ed.dt,
                   # dimensions = "ga:users,ga:pageviews",
                   metrics = "ga:users,ga:pageviews",
                   # max.results = 10000,
                   # sort = "-ga:date",
                   table.id = sprintf("ga:%s", view.id))

# Create the Query Builder object so that the query parameters are validated
ga.query <- QueryBuilder(query.list)

# Extract the data and store it in a data-frame
web <- GetReportData(ga.query, token, split_daywise = F)#, delay = 5)

view.id <- "74798910"
app <- Init(start.date = st.dt,
            end.date = ed.dt,
            metrics = "ga:users,ga:screenviews",
            table.id = sprintf("ga:%s", view.id)) %>% 
  QueryBuilder() %>% GetReportData(token, split_daywise = F)#, delay = 5)

data <- c(web$users, app$users, web$pageviews, app$screenviews)
data


# mylib("RODBC")
dbhandle1 <- odbcDriverConnect("driver={SQL Server};server=10.50.12.182;database=NineYiDW;uid=zackjhuang;pwd=spvc@59rekn!")
# dbhandle2 <- odbcDriverConnect("driver={SQL Server};server=10.50.12.182;database=Rservice;uid=zackjhuang;pwd=spvc@59rekn!")
loaddf <- "select count(distinct s.SalesOrderDM_MemberId), 
case when SalesOrderDM_SupplierTradesOrderSource = N'商店AndroidPhone' then 'APP'
when SalesOrderDM_SupplierTradesOrderSource = N'商店iOSPhone' then 'APP'
else 'WEB' end
from SalesOrderDM s
where s.SalesOrderDM_ShopId = 1257
and s.SalesOrderDM_SalesOrderSlaveDateTime >= '2017-03-13 00:00:00'
and s.SalesOrderDM_SalesOrderSlaveDateTime < '2017-03-20 00:00:00'
and s.SalesOrderDM_Status <> N'失敗'
group by case when SalesOrderDM_SupplierTradesOrderSource = N'商店AndroidPhone' then 'APP'
when SalesOrderDM_SupplierTradesOrderSource = N'商店iOSPhone' then 'APP'
else 'WEB' end"
buyers <- sqlQuery(dbhandle1, loaddf)
buyers






# BigQuery
library(bigrquery)
load("./token_bigq_file")
ValidateToken(token)
project <- "hazel-phoenix-133609" # put your project ID here
dataset <- list_datasets(project)[1]
# ga <- list_tables(project, dataset)
# d <- ga[grep("daily_measurement", ga)]
# sql <- sprintf("SELECT * FROM [%s:%s.%s] WHERE ShopID=1257", project, dataset, d)
# gadf <- query_exec(sql, project = project, max_pages = Inf)


dataset <- list_datasets(project)[2]
ord <- list_tables(project, dataset)
d <- ord[grep("shop_daily_summary", ord)]
sql <- sprintf("SELECT * FROM [%s:%s.%s] WHERE ShopId='1257'", project, dataset, d)
df <- query_exec(sql, project = project, max_pages = Inf)
dt1 <- data.table(df[df$SoDate>=as.Date(st.dt) & df$SoDate<=as.Date(ed.dt),])
buyers <- data.frame(dt1[, (TgCount=sum(TgCount)), by=Source])
order.amount <- data.frame(dt1[, (TgCount=sum(TotalAmount)), by=Source])

dt2 <- df[df$Source!="ALL",]

library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))
gs <- gs_title("vf 需求列表")
df <- gs_read(gs, ws="週報格式")#, range = cell_cols(3:11))
i <- which(is.na(df[nrow(df),]))[2]
x <- unlist(strsplit(unlist(strsplit(colnames(df)[i], split=" "))[2], "-"))
st.dt <- strptime(x[1], format = "(%m/%d")
ed.dt <- strptime(x[2], format = "%m/%d)")
coloumn.index <- LETTERS[i]
prev.column.index <- LETTERS[i-1]
anchor <- sprintf("%s2", col)
formula8 <- sprintf("=%s6/%s2", coloumn.index, coloumn.index)
formula9 <- sprintf("=%s7/%s3", coloumn.index, coloumn.index)
formula11 <- sprintf("=%s10/%s6+%s7", coloumn.index, coloumn.index, coloumn.index)
formula14 <- sprintf("=%s14+%s13", prev.coloumn.index, coloumn.index)
formula16 <- sprintf("=%s16+%s15", prev.coloumn.index, coloumn.index)
input.data <-  c(1:7, formula8, formula9, 10, formula11, 12:13, formula14, 15, formula16)
# gs_edit_cells(gs, input = input.data, ws = "週報格式", anchor = anchor, col_names = T)

